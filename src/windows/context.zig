const std = @import("std");
const Zwl = @import("../Zwl.zig");
const internal = @import("init.zig");
const W32 = @import("w32.zig");

const Window = Zwl.Window;
const Error = Zwl.Error;
const Event = Zwl.Event;

pub const PFD = W32.PIXELFORMATDESCRIPTOR{
    .nVersion = 1,
    .dwFlags = W32.PFD_DRAW_TO_WINDOW |
        W32.PFD_SUPPORT_OPENGL |
        W32.PFD_DOUBLEBUFFER,
    .iPixelType = W32.PFD_TYPE_RGBA,
    .cColorBits = 24,
    .cDepthBits = 8,
    .cStencilBits = 0,
    .cAuxBuffers = 0,
    .iLayerType = 0, //W32.PFD_MAIN_PLANE,
};

pub const GLContext = struct {
    threadlocal var currentContext: ?GLContext = null;

    dc: W32.HDC,
    handle: W32.HGLRC,
    interval: i32,

    pub fn init(self: *GLContext, lib: *Zwl, window: *Window, config: Zwl.GLContext.Config) Error!void {
        const dc = W32.GetDC(window.native.handle) orelse {
            return lib.setError("Cannot get device context from window", .{}, Error.Win32);
        };
        self.dc = dc;

        const format: i32 = if (@as(u56, @bitCast(config.pixelFormat)) != 0) blk: {
            if (lib.native.wglChoosePixelFormatARB) |wglChoosePixelFormatARB| {
                const attribs = [_:.{ 0, 0 }][2]i32{
                    .{ W32.WGL_DRAW_TO_WINDOW_ARB, 1 },
                    .{ W32.WGL_SUPPORT_OPENGL_ARB, 1 },
                    .{ W32.WGL_DOUBLE_BUFFER_ARB, 1 },
                    .{ W32.WGL_PIXEL_TYPE_ARB, W32.WGL_TYPE_RGBA_ARB },
                    .{ W32.WGL_COLOR_BITS_ARB, 24 },
                    .{ W32.WGL_RED_BITS_ARB, config.pixelFormat.redBits },
                    .{ W32.WGL_GREEN_BITS_ARB, config.pixelFormat.greenBits },
                    .{ W32.WGL_BLUE_BITS_ARB, config.pixelFormat.blueBits },
                    .{ W32.WGL_ALPHA_BITS_ARB, config.pixelFormat.alphaBits },
                    .{ W32.WGL_STENCIL_BITS_ARB, config.pixelFormat.stencilBits },
                    .{ W32.WGL_DEPTH_BITS_ARB, config.pixelFormat.depthBits },
                    .{ W32.WGL_SAMPLE_BUFFERS_ARB, 1 },
                    .{ W32.WGL_SAMPLES_ARB, config.pixelFormat.samples },
                };
                var nFormats: u32 = undefined;
                var result: i32 = undefined;
                if (wglChoosePixelFormatARB(
                    dc,
                    &attribs,
                    null,
                    1,
                    @ptrCast(&result),
                    &nFormats,
                ) == 0) {
                    return lib.setError("Cannot find suitable pixel format", .{}, Error.Win32);
                }
                break :blk result;
            } else {
                return lib.setError("wglChoosePixelFormatARB unavailable while requested specific pixel format", .{}, Error.Win32);
            }
        } else W32.ChoosePixelFormat(dc, &PFD);

        if (W32.SetPixelFormat(dc, format, &PFD) == 0) {
            return lib.setError("Cannot set pixel format for device context: {d}", .{W32.GetLastError()}, Error.Win32);
        }

        if (config.version.api == .opengl and lib.native.wglCreateContextAttribsARB == null) {
            if (config.forward) {
                return lib.setError("Cannot set forward compatibility without WGL_ARB_create_context (unavailable)", .{}, Error.Win32);
            }
            if (config.profile != .any) {
                return lib.setError("Cannot set opengl profile without WGL_ARB_create_context_profile (unavailable)", .{}, Error.Win32);
            }
        } else if (config.version.api == .opengl_es) {
            @panic("OpenGL ES not yet implemented");
        }

        if (lib.native.wglCreateContextAttribsARB) |wglCreateContextAttribsARB| {
            var attribs: [4:.{ 0, 0 }][2]i32 = undefined;
            var index: u32 = 0;
            var mask: u32 = 0;
            var flags: u32 = 0;

            if (config.version.api == .opengl) {
                if (config.forward) {
                    flags |= W32.WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB;
                }

                if (config.profile == .core) {
                    mask |= W32.WGL_CONTEXT_CORE_PROFILE_BIT_ARB;
                } else if (config.profile == .compat) {
                    mask |= W32.WGL_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB;
                }
            } else {
                @panic("OpenGL ES not yet implemented");
            }

            if (config.version.major != 0 or
                config.version.minor != 0)
            {
                std.debug.assert(config.version.major != 0);
                attribs[index] = .{ W32.WGL_CONTEXT_MAJOR_VERSION_ARB, config.version.major };
                attribs[index + 1] = .{ W32.WGL_CONTEXT_MINOR_VERSION_ARB, config.version.minor };
                index += 2;
            }

            if (config.debug) {
                flags |= W32.WGL_CONTEXT_DEBUG_BIT_ARB;
            }

            if (flags != 0) {
                attribs[index] = .{ W32.WGL_CONTEXT_FLAGS_ARB, @bitCast(flags) };
                index += 1;
            }
            if (mask != 0) {
                attribs[index] = .{ W32.WGL_CONTEXT_PROFILE_MASK_ARB, @bitCast(mask) };
                index += 1;
            }

            self.handle = wglCreateContextAttribsARB(
                dc,
                if (config.share) |share| share.native.handle else null,
                @ptrCast(&attribs),
            ) orelse {
                switch (W32.GetLastError()) {
                    @as(i32, @truncate(0xc0070000)) | W32.ERROR_INVALID_VERSION_ARB => {
                        if (config.version.api == .opengl) {
                            return lib.setError(
                                "Driver does not support OpenGL {d}.{d}",
                                .{ config.version.major, config.version.minor },
                                Error.Win32,
                            );
                        } else {
                            return lib.setError(
                                "Driver does not support OpenGL ES {d}.{d}",
                                .{ config.version.major, config.version.minor },
                                Error.Win32,
                            );
                        }
                    },
                    @as(i32, @truncate(0xc0070000)) | W32.ERROR_INVALID_PROFILE_ARB => {
                        return lib.setError(
                            "Driver does not support requested OpenGL profile",
                            .{},
                            Error.Win32,
                        );
                    },
                    @as(i32, @truncate(0xc0070000)) | W32.ERROR_INCOMPATIBLE_DEVICE_CONTEXTS_ARB => {
                        return lib.setError(
                            "The share context is not compatible with the requested context",
                            .{},
                            Error.Win32,
                        );
                    },
                    else => {
                        if (config.version.api == .opengl) {
                            return lib.setError(
                                "Failed to create OpenGL context",
                                .{},
                                Error.Win32,
                            );
                        } else {
                            return lib.setError(
                                "Failed to create OpenGL ES context",
                                .{},
                                Error.Win32,
                            );
                        }
                    },
                }
            };
            return;
        }

        self.handle = W32.wglCreateContext(dc) orelse {
            return lib.setError("Cannot create WGL context", .{}, Error.Win32);
        };
        errdefer _ = W32.wglDeleteContext(self.handle);

        if (config.share) |share| {
            if (W32.wglShareLists(share.native.handle, self.handle) == 0) {
                return lib.setError(
                    "Failed to enable sharing with specified OpenGL context",
                    .{},
                    Error.Win32,
                );
            }
        }
    }
    pub fn deinit(self: *GLContext) void {
        _ = W32.wglDeleteContext(self.handle);
    }

    pub fn makeCurrent(lib: *Zwl, opt_ctx: ?*Zwl.GLContext) Error!void {
        _ = lib;
        currentContext = null;
        if (opt_ctx) |ctx| {
            if (W32.wglMakeCurrent(ctx.native.dc, ctx.native.handle) == 0) {
                return ctx.owner.owner.setError("Failed to make GLContext current", .{}, Error.Win32);
            }
            currentContext = ctx.native;
        } else _ = W32.wglMakeCurrent(undefined, null);
    }

    pub fn swapBuffers(ctx: *Zwl.GLContext) Error!void {
        _ = W32.SwapBuffers(ctx.native.dc);
    }

    pub fn swapInterval(lib: *Zwl, interval: i32) Error!void {
        if (lib.native.wglSwapIntervalEXT) |wglSwapIntervalEXT| {
            if (wglSwapIntervalEXT(interval) == 0) {
                return lib.setError("Cannot find current context", .{}, Error.Win32);
            }
        } else {
            return lib.setError("swapInterval requires wglSwapIntervalEXT (unavailable)", .{}, Error.Win32);
        }
    }
};
