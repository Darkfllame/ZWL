const std = @import("std");
const builtin = @import("builtin");
const config = @import("config");
const ZWL = @import("zwl.zig");

const Error = ZWL.Error;
const Window = ZWL.Window;
const Zwl = ZWL.Zwl;

pub const GLContext = struct {
    owner: *Window,
    config: Config,
    native: ZWL.platform.GLContext,

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
        errdefer allocator.destroy(self);
        self.owner = window;
        self.config = ctxConfig;
        try lib.platform.glContext.init(&self.native, lib, window, ctxConfig);
        return self;
    }
    pub fn destroy(self: *GLContext) void {
        const lib = self.owner.owner;
        lib.platform.glContext.deinit(&self.native);
        lib.allocator.destroy(self);
    }

    pub inline fn makeCurrent(lib: *Zwl, opt_ctx: ?*GLContext) Error!void {
        if (opt_ctx) |ctx| {
            if (ctx.owner.owner != lib) {
                @panic("Bad library passed to GLContext.makeCurrent");
            }
        }
        return lib.platform.glContext.makeCurrent(lib, opt_ctx);
    }
    pub inline fn swapBuffers(ctx: *GLContext) Error!void {
        return ctx.owner.owner.platform.glContext.swapBuffers(ctx);
    }
};
