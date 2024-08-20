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

    pub const VersionAPI = enum(u2) {
        opengl,
        opengl_es,
    };
    pub const OpenGLProfile = enum(u2) {
        any,
        core,
        compat,
    };
    pub const Version = struct {
        api: VersionAPI = .opengl,
        major: u8 = 1,
        minor: u8 = 0,
    };
    pub const Config = struct {
        version: Version = .{},
        debug: bool = false,
        forward: bool = false,
        profile: OpenGLProfile = .any,
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

    pub fn makeCurrent(lib: *Zwl, opt_ctx: ?*GLContext) Error!void {
        if (opt_ctx) |ctx| {
            if (ctx.owner.owner != lib) {
                @panic("Bad library passed to GLContext.makeCurrent");
            }
        }
        return lib.platform.glContext.makeCurrent(lib, opt_ctx);
    }
    pub fn swapBuffers(ctx: *GLContext) Error!void {
        return ctx.owner.owner.platform.glContext.swapBuffers(ctx);
    }
    pub fn swapInterval(lib: *Zwl, interval: u32) Error!void {
        return lib.platform.glContext.swapInterval(lib, interval);
    }
};
