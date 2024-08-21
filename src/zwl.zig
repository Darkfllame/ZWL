const std = @import("std");
const builtin = @import("builtin");
const config = @import("config");
const window = @import("window.zig");
const event = @import("event.zig");
const context = @import("context.zig");

const Allocator = std.mem.Allocator;

pub const platform = switch (builtin.os.tag) {
    .windows => @import("windows/platform.zig"),
    .linux => @import("linux/platform.zig"),
    .macos => @import("macos/platform.zig"),
    else => @compileError("Unsupported target"),
};

pub const Window = window.Window;
pub const Event = event.Event;
pub const Key = event.Key;
pub const GLContext = context.GLContext;

pub const FunctionLoaderError = error{
    LibraryNotFound,
    FunctionNotFound,
};

pub const Error = FunctionLoaderError || error{
    OutOfMemory,
    InvalidUtf8,
    Win32,
    Wayland,
    X11,
    Cocoa,
};

pub const InitConfig = struct {};

pub const Zwl = struct {
    allocator: Allocator,
    errorBuffer: [config.ERROR_BUFFER_SIZE]u8,
    errFormatBuffer: [config.ERROR_BUFFER_SIZE]u8,
    currentError: ?[]u8,
    platform: Platform,
    native: platform.NativeData,

    pub fn init(self: *Zwl, allocator: Allocator, iConfig: InitConfig) Error!void {
        _ = iConfig;
        self.* = .{
            .allocator = allocator,
            .errorBuffer = [_]u8{0} ** config.ERROR_BUFFER_SIZE,
            .errFormatBuffer = [_]u8{0} ** config.ERROR_BUFFER_SIZE,
            .currentError = null,
            .native = undefined,
            .platform = undefined,
        };
        comptime {
            if (@TypeOf(platform.setPlatform) != fn (*Platform) Error!void) {
                @compileError("Expected platform.setPlatform to be 'fn (*Platform) Error!void'");
            }
        }
        try platform.setPlatform(&self.platform);
        try self.platform.init(self);
    }
    pub fn deinit(self: *Zwl) void {
        self.platform.deinit(self);
    }

    pub fn clearError(self: *Zwl) void {
        self.currentError = null;
    }
    pub fn getError(self: *const Zwl) []const u8 {
        return self.currentError orelse config.DEFAULT_ERROR_MESSAGE;
    }
    pub fn setError(self: *Zwl, comptime fmt: []const u8, args: anytype, err: anytype) @TypeOf(err) {
        if (@typeInfo(@TypeOf(err)) != .ErrorSet) {
            @compileError("'err' must be an error");
        }

        self.clearError();

        const formatted = std.fmt.bufPrint(&self.errFormatBuffer, fmt, args) catch blk: {
            const TRUNC_MESSAGE = " (truncated)";
            @memcpy(
                self.errFormatBuffer[self.errFormatBuffer.len - TRUNC_MESSAGE.len ..],
                TRUNC_MESSAGE,
            );
            break :blk &self.errFormatBuffer;
        };

        self.currentError = self.errorBuffer[0..formatted.len];

        @memcpy(self.currentError.?, formatted);

        return err;
    }

    pub const createWindow = Window.create;
    pub const createMessageBox = Window.createMessageBox;

    pub const pollEvent = event.pollEvent;

    pub const makeContextCurrent = GLContext.makeCurrent;
};

pub const NativeFunction = struct {
    name: [:0]const u8,
    type: type,
};

pub const Platform = struct {
    init: *const fn (*Zwl) Error!void,
    deinit: *const fn (*Zwl) void,
    window: struct {
        init: *const fn (*platform.Window, *Zwl, Window.Config) Error!void,
        deinit: *const fn (*platform.Window) void,
        setPosition: *const fn (*Window, u32, u32) void,
        getSize: *const fn (*Window, ?*u32, ?*u32) void,
        setSize: *const fn (*Window, u32, u32) void,
        setSizeLimits: *const fn (*Window, ?u32, ?u32, ?u32, ?u32) void,
        getFramebufferSize: *const fn (*Window, ?*u32, ?*u32) void,
        setVisible: *const fn (*Window, bool) void,
        setTitle: *const fn (*Window, []const u8) Error!void,
        getTitle: *const fn (*Window) []const u8,
        isFocused: *const fn (*Window) bool,
        getMousePos: *const fn (*Window, ?*u32, ?*u32) void,
        setMousePos: *const fn (*Window, u32, u32) void,
        setMouseVisible: *const fn (*Window, bool) void,
        createMessageBox: *const fn (*Zwl, Window.MBConfig) Error!Window.MBButton,
    },
    event: struct {
        pollEvent: *const fn (*Zwl, ?*Window) Error!?Event,
    },
    glContext: struct {
        init: *const fn (*platform.GLContext, *Zwl, *Window, GLContext.Config) Error!void,
        deinit: *const fn (*platform.GLContext) void,
        makeCurrent: *const fn (*Zwl, ?*GLContext) Error!void,
        swapBuffers: *const fn (*GLContext) Error!void,
        swapInterval: *const fn (*Zwl, u32) Error!void,
    },
};

pub fn FunctionLoader(comptime libName: []const u8, comptime decls: []const NativeFunction) type {
    const Type = std.builtin.Type;
    comptime var fields: [decls.len]Type.StructField = undefined;
    for (decls, 0..) |d, i| {
        fields[i] = .{
            .name = d.name,
            .type = *const GetFunctionType(d.type),
            .default_value = null,
            .is_comptime = false,
            .alignment = @alignOf(*const GetFunctionType(d.type)),
        };
    }
    const FuncList = @Type(Type{ .Struct = .{
        .layout = .auto,
        .backing_integer = null,
        .fields = &fields,
        .decls = &.{},
        .is_tuple = false,
    } });
    return struct {
        const Self = @This();
        const DynLib = std.DynLib;

        lib: DynLib,
        funcs: FuncList,

        pub fn init(self: *Self) FunctionLoaderError!void {
            var dl = DynLib.open(libName) catch return error.LibraryNotFound;
            errdefer dl.close();
            self.lib = dl;

            inline for (decls) |d| {
                @field(self.funcs, d.name) = dl.lookup(*const GetFunctionType(d.type), d.name) orelse
                    return error.FunctionNotFound;
            }
        }
        pub fn deinit(self: *Self) void {
            self.lib.close();
        }
    };
}

pub fn checkNativeDecls(comptime T: type, comptime decls: []const NativeFunction) void {
    for (decls) |rDecl| {
        if (!@hasDecl(T, rDecl.name) and
            @TypeOf(@field(T, rDecl.name)) == rDecl.type)
        {
            @compileError("Expected " ++ @typeName(T) ++ " to have \"" ++
                rDecl.name ++ "\" field of type: " ++ @typeName(rDecl.type));
        }
    }
}

pub fn MBpanic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace, ret_addr: ?usize) noreturn {
    var text: [4096]u8 = undefined;
    var len: usize = 0;
    var fbs = std.io.fixedBufferStream(&text);
    const first_ret_addr = ret_addr orelse @returnAddress();
    if (std.debug.getSelfDebugInfo()) |dbi| {
        std.debug.writeCurrentStackTrace(
            fbs.writer(),
            dbi,
            .no_color,
            first_ret_addr,
        ) catch {};
    } else |_| {}
    if (error_return_trace) |ert| {
        ert.format("", .{}, fbs.writer()) catch {};
    }
    len = fbs.pos;
    if (len == 0) {
        const noErrMessage = "No Error message";
        len = noErrMessage.len;
        @memcpy(text[0..noErrMessage.len], noErrMessage);
    }
    const mbText = text[0..len];

    var title: [4096]u8 = undefined;
    fbs = std.io.fixedBufferStream(&title);
    len = 0;
    if (@import("builtin").single_threaded) {
        fbs.writer().print("panic: {s}", .{msg}) catch {};
    } else {
        fbs.writer().print("thread {d} panic: {s}", .{ std.Thread.getCurrentId(), msg }) catch {};
    }
    len = fbs.pos;

    var zwl: Zwl = undefined;
    zwl.init(std.heap.page_allocator, .{}) catch
        std.builtin.default_panic(msg, @errorReturnTrace(), null);

    const ret = zwl.createMessageBox(.{
        .title = title[0..len],
        .text = mbText,
        .icon = .@"error",
    });
    zwl.deinit();
    if (ret) |_| {} else |_| {}
    std.builtin.default_panic(msg, error_return_trace, first_ret_addr);
}

fn GetFunctionType(comptime T: type) type {
    const tinfo = @typeInfo(T);

    const noOptTinfo = if (tinfo == .Optional)
        @typeInfo(tinfo.Optional.child)
    else
        tinfo;

    const noPtrTinfo = if (noOptTinfo == .Pointer)
        @typeInfo(noOptTinfo.Pointer.child)
    else
        noOptTinfo;

    if (noPtrTinfo != .Fn) {
        @compileError("Expected function type, got: " ++ @typeName(T));
    }

    return @Type(noPtrTinfo);
}
