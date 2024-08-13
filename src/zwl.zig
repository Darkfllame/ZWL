const std = @import("std");
const builtin = @import("builtin");
const config = @import("config");
const window = @import("window.zig");
const event = @import("event.zig");

const Allocator = std.mem.Allocator;

const Native = switch (builtin.os.tag) {
    .windows => @import("windows/init.zig"),
    else => @compileError("Unsupported target"),
};

pub const Window = window.Window;
pub const Event = event.Event;
pub const Key = event.Key;

pub const Error = error{
    OutOfMemory,
    Win32,
    InvalidUtf8,
};

pub const InitConfig = struct {};

pub const Zwl = struct {
    allocator: Allocator,
    errorBuffer: [config.ERROR_BUFFER_SIZE]u8,
    errFormatBuffer: [config.ERROR_BUFFER_SIZE]u8,
    currentError: ?[]u8,
    native: Native.NativeData,

    pub fn init(self: *Zwl, allocator: Allocator, iConfig: InitConfig) Error!void {
        _ = iConfig;
        self.* = .{
            .allocator = allocator,
            .errorBuffer = [_]u8{0} ** config.ERROR_BUFFER_SIZE,
            .errFormatBuffer = [_]u8{0} ** config.ERROR_BUFFER_SIZE,
            .currentError = null,
            .native = undefined,
        };
        try Native.init(self);
    }
    pub fn deinit(self: *Zwl) void {
        Native.deinit(self);
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

    pub const pollEvent = event.pollEvent;
};

pub const NativeDecl = struct {
    name: [:0]const u8,
    type: type,
};

pub fn checkNativeDecls(comptime T: type, comptime decls: []const NativeDecl) void {
    for (decls) |rDecl| {
        if (!@hasDecl(T, rDecl.name) and
            @TypeOf(@field(T, rDecl.name)) == rDecl.type)
        {
            @compileError("Expected " ++ @typeName(T) ++ " to have \"" ++
                rDecl.name ++ "\" field of type: " ++ @typeName(rDecl.type));
        }
    }
}
