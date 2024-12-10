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

pub const Error = error{
    Cocoa,
    InvalidUtf8,
    OutOfMemory,
    QueueFull,
    X11,
    Wayland,
    Win32,
};

pub const Config = struct {};

const Zwl = @This();

comptime platform: Platform = if (@hasDecl(platform, "platform") and @TypeOf(platform.platform) == Platform)
    platform.platform
else
    @compileError("Expected platform.setPlatform to be 'fn (*Platform) Error!void'"),

allocator: Allocator,
errorBuffer: [config.ERROR_BUFFER_SIZE]u8,
errFormatBuffer: [config.ERROR_BUFFER_SIZE]u8,
currentError: ?[]u8,
eventQueueSize: usize,
eventQueue: [config.EVENT_QUEUE_SIZE]Event,
native: platform.NativeData,

pub fn init(self: *Zwl, allocator: Allocator, _config: Config) Error!void {
    @memset(std.mem.asBytes(self), 0);
    self.allocator = allocator;
    try self.platform.init(self, _config);
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

pub fn keyName(self: *const Zwl, key: Key) ?[:0]const u8 {
    return self.platform.keyName(self, key);
}

pub const createWindow = Window.create;
pub const createMessageBox = Window.createMessageBox;

pub const pollEvent = event.pollEvent;

pub const makeContextCurrent = GLContext.makeCurrent;
pub const swapInterval = GLContext.swapInterval;

pub const Platform = struct {
    init: *const fn (*Zwl, Config) Error!void,
    deinit: *const fn (*Zwl) void,
    keyName: *const fn (*const Zwl, Key) [:0]const u8,
    window: struct {
        createMessageBox: *const fn (*Zwl, Window.MBConfig) Error!Window.MBButton,
        init: *const fn (*platform.Window, *Zwl, Window.Config) Error!void,
        deinit: *const fn (*platform.Window) void,
        setPosition: *const fn (*Window, u32, u32) void,
        setSize: *const fn (*Window, u32, u32) void,
        setSizeLimits: *const fn (*Window, ?u32, ?u32, ?u32, ?u32) void,
        getFramebufferSize: *const fn (*Window, ?*u32, ?*u32) void,
        setVisible: *const fn (*Window, bool) void,
        setTitle: *const fn (*Window, []const u8) Error!void,
        isFocused: *const fn (*Window) bool,
        getMousePos: *const fn (*Window, ?*u32, ?*u32) void,
        setMousePos: *const fn (*Window, u32, u32) void,
        setMouseVisible: *const fn (*Window, bool) void,
        setFocus: *const fn (*Window) void,
        setMouseConfined: *const fn (*Window, bool) void,
    },
    event: struct {
        pollEvent: *const fn (*Zwl, ?*Window) Error!void,
    },
    glContext: struct {
        init: *const fn (*platform.GLContext, *Zwl, *Window, GLContext.Config) Error!void,
        deinit: *const fn (*platform.GLContext) void,
        makeCurrent: *const fn (*Zwl, ?*GLContext) Error!void,
        swapBuffers: *const fn (*GLContext) Error!void,
        swapInterval: *const fn (*Zwl, i32) Error!void,
    },
};

pub fn MBpanic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace, ret_addr: ?usize) noreturn {
    @setCold(true);
    const S = struct {
        var inPanic: bool = false;
    };
    if (S.inPanic) {
        std.builtin.default_panic("Panic in panic, aborting", error_return_trace, null);
    }
    S.inPanic = true;
    const first_ret_addr = ret_addr orelse @returnAddress();

    var text: [4096]u8 = undefined;
    var len: usize = 0;
    var fbs = std.io.fixedBufferStream(&text);
    fbs.writer().print("{s}\n", .{msg}) catch {};
    if (!builtin.strip_debug_info) {
        if (std.debug.getSelfDebugInfo()) |dbi| {
            std.debug.writeCurrentStackTrace(
                fbs.writer(),
                dbi,
                .no_color,
                first_ret_addr,
            ) catch {};
        } else |_| {}
    }
    if (error_return_trace) |ert| {
        ert.format("", .{}, fbs.writer()) catch {};
    }
    len = fbs.pos;
    const mbText = text[0..len];

    var title: [4096]u8 = undefined;
    fbs = std.io.fixedBufferStream(&title);
    len = 0;
    if (@import("builtin").single_threaded) {
        fbs.writer().print("panic", .{}) catch {};
    } else {
        fbs.writer().print("thread {d} panic", .{std.Thread.getCurrentId()}) catch {};
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

comptime {
    if (@sizeOf(c_int) != 4) {
        @compileError("Bad target platform, c_int MUST be 32 bits");
    }
}
