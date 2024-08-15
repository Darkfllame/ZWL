const std = @import("std");
const ZWL = @import("../zwl.zig");
const internal = @import("init.zig");
const W32 = @import("w32.zig");

const Window = ZWL.Window;
const Error = ZWL.Error;
const Event = ZWL.Event;
const Zwl = ZWL.Zwl;

const USER32 = @TypeOf(@as(internal.NativeData, undefined).user32.funcs);
const OPENGL32 = @TypeOf(@as(internal.NativeData, undefined).opengl32.funcs);
const GDI32 = @TypeOf(@as(internal.NativeData, undefined).gdi32.funcs);

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
    var previousCurrent: ?GLContext = null;

    dc: W32.HDC,
    user32: *const USER32,
    opengl32: *const OPENGL32,
    gdi32: *const GDI32,
    handle: W32.HGLRC,
    interval: i32,

    pub fn init(self: *GLContext, lib: *Zwl, window: *Window, config: ZWL.GLContext.Config) Error!void {
        _ = config; // autofix
        self.user32 = &lib.native.user32.funcs;
        self.opengl32 = &lib.native.opengl32.funcs;
        self.gdi32 = &lib.native.gdi32.funcs;
        const user32 = self.user32;
        const opengl32 = self.opengl32;
        const gdi32 = self.gdi32;
        const dc = user32.GetDC(window.native.handle) orelse {
            return lib.setError("Cannot get device context from window", .{}, Error.Win32);
        };
        self.dc = dc;

        if (gdi32.SetPixelFormat(dc, gdi32.ChoosePixelFormat(dc, &PFD), &PFD) == 0) {
            return lib.setError("Cannot set pixel format for device context", .{}, Error.Win32);
        }

        const handle = opengl32.wglCreateContext(dc) orelse {
            return lib.setError("Cannot create WGL context", .{}, Error.Win32);
        };
        errdefer _ = opengl32.wglDeleteContext(handle);
        self.handle = handle;
    }
    pub fn deinit(self: *GLContext) void {
        _ = self.opengl32.wglDeleteContext(self.handle);
    }

    pub fn makeCurrent(lib: *Zwl, opt_ctx: ?*ZWL.GLContext) Error!void {
        const opengl32 = &lib.native.opengl32.funcs;
        if (previousCurrent) |previous| {
            _ = opengl32.wglMakeCurrent(previous.dc, null);
            previousCurrent = null;
        }
        if (opt_ctx) |ctx| {
            if (opengl32.wglMakeCurrent(ctx.native.dc, ctx.native.handle) == 0) {
                return ctx.owner.owner.setError("Failed to make GLContext current", .{}, Error.Win32);
            }
            previousCurrent = ctx.native;
        }
    }

    pub fn swapBuffers(ctx: *ZWL.GLContext) Error!void {
        _ = ctx.native.gdi32.SwapBuffers(ctx.native.dc);
    }
};
