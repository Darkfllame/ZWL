const std = @import("std");
const builtin = @import("builtin");
const Zwl = @import("Zwl.zig");

const Error = Zwl.Error;
const Window = Zwl.Window;

pub const GLContext = struct {
    owner: *Window,
    config: Config,
    native: Zwl.platform.GLContext,

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
        major: u8 = 0,
        minor: u8 = 0,
    };
    pub const Config = struct {
        version: Version = .{},
        debug: bool = builtin.mode == .Debug,
        forward: bool = false,
        profile: OpenGLProfile = .any,
        share: ?*GLContext = null,
        pixelFormat: PixelFormat = .{},
    };
    pub const PixelFormat = packed struct(u56) {
        /// 0 means default
        redBits: u8 = 0,
        /// 0 means default
        greenBits: u8 = 0,
        /// 0 means default
        blueBits: u8 = 0,
        /// 0 means default
        alphaBits: u8 = 0,
        /// 0 means default
        depthBits: u8 = 0,
        /// 0 means default
        stencilBits: u8 = 0,
        /// 0 means default
        samples: u8 = 0,
    };

    pub fn create(window: *Window, config: Config) Error!*GLContext {
        const lib = window.owner;
        const allocator = lib.allocator;
        const self = allocator.create(GLContext) catch |e| {
            return lib.setError("Cannot create GLContext", .{}, e);
        };
        errdefer allocator.destroy(self);
        try self.init(window, config);
        return self;
    }
    pub fn init(self: *GLContext, window: *Window, config: Config) Error!void{
        const lib = window.owner;
        self.owner = window;
        self.config = config;
        try lib.platform.glContext.init(&self.native, lib, window, config);
    }
    pub fn destroy(self: *GLContext) void {
        const lib = self.owner.owner;
        self.deinit();
        lib.allocator.destroy(self);
    }
    pub fn deinit(self: *GLContext) void {
        const lib = self.owner.owner;
        lib.platform.glContext.deinit(&self.native);
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
    pub fn swapInterval(lib: *Zwl, interval: i32) Error!void {
        return lib.platform.glContext.swapInterval(lib, interval);
    }
};
