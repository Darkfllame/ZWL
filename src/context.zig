const std = @import("std");
const builtin = @import("builtin");
const config = @import("config");
const ZWL = @import("zwl.zig");

const Error = ZWL.Error;
const Window = ZWL.Window;
const Zwl = ZWL.Zwl;

const Native = switch (builtin.os.tag) {
    .windows => @import("windows/context.zig"),
    .linux => if (config.USE_WAYLAND)
        @import("linux/wayland/context.zig")
    else
        @import("linux/xorg/context.zig"),
    .macos => @import("macos/context.zig"),
    .ios => @import("ios/context.zig"),
    else => @compileError("Unsupported target"),
};

comptime {
    ZWL.checkNativeDecls(Native, &.{});
}

pub const GLContext = struct {
    owner: *Window,
    config: Config,
    native: Native.GLContext,

    pub const ClientAPI = enum(u2) {
        /// Currently unused on:
        /// - Windows
        none,
        /// Currently unused on:
        /// - Windows
        opengl,
        /// Currently unused on:
        /// - Windows
        opengl_es,
    };
    pub const Config = struct {
        /// Currently unused on:
        /// - Windows
        client: ClientAPI = .none,
        /// Currently unused on:
        /// - Windows
        major: u8 = 1,
        /// Currently unused on:
        /// - Windows
        minor: u8 = 0,
        /// Currently unused on:
        /// - Windows
        debug: bool = false,
        /// Currently unused on:
        /// - Windows
        share: ?*GLContext = null,
    };

    pub fn create(window: *Window, ctxConfig: Config) Error!*GLContext {
        const lib = window.owner;
        const allocator = lib.allocator;
        const self = allocator.create(GLContext) catch |e| {
            return lib.setError("Cannot create GLContext", .{}, e);
        };
        self.owner = window;
        self.config = ctxConfig;
        try self.native.init(lib, window, ctxConfig);
        errdefer allocator.destroy(self);
        return self;
    }
    pub fn destroy(self: *GLContext) void {
        self.native.deinit();
        self.owner.owner.allocator.destroy(self);
    }

    pub const makeCurrent = Native.GLContext.makeCurrent;
    pub const swapBuffers = Native.GLContext.swapBuffers;
};
