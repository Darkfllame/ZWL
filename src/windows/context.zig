const std = @import("std");
const ZWL = @import("../zwl.zig");
const W32 = @import("w32.zig");

const Window = ZWL.Window;
const Error = ZWL.Error;
const Event = ZWL.Event;
const Zwl = ZWL.Zwl;

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
    handle: W32.HGLRC,
    interval: i32,

    pub fn init(self: *GLContext, lib: *Zwl, window: *Window, config: ZWL.GLContext.Config) Error!void {
        _ = config; // autofix
        // const GUID_DEVINTERFACE_HID = W32.GUID{
        //     .Data1 = 0x4d1e55b2,
        //     .Data2 = 0xf16f,
        //     .Data3 = 0x11cf,
        //     .Data4 = .{
        //         0x88, 0xcb, 0x00, 0x11,
        //         0x11, 0x00, 0x00, 0x30,
        //     },
        // };
        const dc = W32.GetDC(window.native.handle) orelse {
            return lib.setError("Cannot get device context from window", .{}, Error.Win32);
        };
        self.dc = dc;

        if (W32.SetPixelFormat(dc, W32.ChoosePixelFormat(dc, &PFD), &PFD) == 0) {
            return lib.setError("Cannot set pixel format for device context", .{}, Error.Win32);
        }

        const handle = W32.wglCreateContext(dc) orelse {
            return lib.setError("Cannot create WGL context", .{}, Error.Win32);
        };
        errdefer _ = W32.wglDeleteContext(handle);
        self.handle = handle;
    }
    pub fn deinit(self: *GLContext) void {
        _ = W32.wglDeleteContext(self.handle);
    }

    pub fn makeCurrent(opt_ctx: ?*ZWL.GLContext) Error!void {
        if (previousCurrent) |previous| {
            _ = W32.wglMakeCurrent(previous.dc, null);
            previousCurrent = null;
        }
        if (opt_ctx) |ctx| {
            if (W32.wglMakeCurrent(ctx.native.dc, ctx.native.handle) == 0) {
                return ctx.owner.owner.setError("Failed to make GLContext current", .{}, Error.Win32);
            }
            previousCurrent = ctx.native;
        }
    }

    pub fn swapBuffers(ctx: *ZWL.GLContext) Error!void {
        _ = W32.SwapBuffers(ctx.native.dc);
    }
};
