const std = @import("std");
const ZWL = @import("../zwl.zig");
const W32 = @import("w32.zig");
const window = @import("window.zig");
const event = @import("event.zig");
const context = @import("context.zig");

const unicode = std.unicode;
const Allocator = std.mem.Allocator;

const Platform = ZWL.Platform;
const Error = ZWL.Error;
const Key = ZWL.Key;
const Zwl = ZWL.Zwl;

var initCount: u32 = 0;

pub const WND_CLASS_NAME = utf8ToUtf16Z(undefined, "ZWL_WND") catch unreachable;

pub const KEYCODES: [512]Key = blk: {
    var keycodes = std.mem.zeroes([512]Key);

    keycodes[0x002] = .@"1";
    keycodes[0x003] = .@"2";
    keycodes[0x004] = .@"3";
    keycodes[0x005] = .@"4";
    keycodes[0x006] = .@"5";
    keycodes[0x007] = .@"6";
    keycodes[0x008] = .@"7";
    keycodes[0x009] = .@"8";
    keycodes[0x00A] = .@"9";
    keycodes[0x00B] = .@"0";
    keycodes[0x01E] = .a;
    keycodes[0x030] = .b;
    keycodes[0x02E] = .c;
    keycodes[0x020] = .d;
    keycodes[0x012] = .e;
    keycodes[0x021] = .f;
    keycodes[0x022] = .g;
    keycodes[0x023] = .h;
    keycodes[0x017] = .i;
    keycodes[0x024] = .j;
    keycodes[0x025] = .k;
    keycodes[0x026] = .l;
    keycodes[0x032] = .m;
    keycodes[0x031] = .n;
    keycodes[0x018] = .o;
    keycodes[0x019] = .p;
    keycodes[0x010] = .q;
    keycodes[0x013] = .r;
    keycodes[0x01F] = .s;
    keycodes[0x014] = .t;
    keycodes[0x016] = .u;
    keycodes[0x02F] = .v;
    keycodes[0x011] = .w;
    keycodes[0x02D] = .x;
    keycodes[0x015] = .y;
    keycodes[0x02C] = .z;

    keycodes[0x028] = .apostrophe;
    keycodes[0x02B] = .backslash;
    keycodes[0x033] = .comma;
    keycodes[0x00D] = .equal;
    keycodes[0x029] = .grave_accent;
    keycodes[0x01A] = .left_bracket;
    keycodes[0x00C] = .minus;
    keycodes[0x034] = .period;
    keycodes[0x01B] = .right_bracket;
    keycodes[0x027] = .semicolon;
    keycodes[0x035] = .slash;
    keycodes[0x056] = .world_2;

    keycodes[0x00E] = .backspace;
    keycodes[0x153] = .delete;
    keycodes[0x14F] = .end;
    keycodes[0x01C] = .enter;
    keycodes[0x001] = .escape;
    keycodes[0x147] = .home;
    keycodes[0x152] = .insert;
    keycodes[0x15D] = .menu;
    keycodes[0x151] = .page_down;
    keycodes[0x149] = .page_up;
    keycodes[0x045] = .pause;
    keycodes[0x039] = .space;
    keycodes[0x00F] = .tab;
    keycodes[0x03A] = .caps_lock;
    keycodes[0x145] = .num_lock;
    keycodes[0x046] = .scroll_lock;
    keycodes[0x03B] = .f1;
    keycodes[0x03C] = .f2;
    keycodes[0x03D] = .f3;
    keycodes[0x03E] = .f4;
    keycodes[0x03F] = .f5;
    keycodes[0x040] = .f6;
    keycodes[0x041] = .f7;
    keycodes[0x042] = .f8;
    keycodes[0x043] = .f9;
    keycodes[0x044] = .f10;
    keycodes[0x057] = .f11;
    keycodes[0x058] = .f12;
    keycodes[0x064] = .f13;
    keycodes[0x065] = .f14;
    keycodes[0x066] = .f15;
    keycodes[0x067] = .f16;
    keycodes[0x068] = .f17;
    keycodes[0x069] = .f18;
    keycodes[0x06A] = .f19;
    keycodes[0x06B] = .f20;
    keycodes[0x06C] = .f21;
    keycodes[0x06D] = .f22;
    keycodes[0x06E] = .f23;
    keycodes[0x076] = .f24;
    keycodes[0x038] = .left_alt;
    keycodes[0x01D] = .left_control;
    keycodes[0x02A] = .left_shift;
    keycodes[0x15B] = .left_super;
    keycodes[0x137] = .print_screen;
    keycodes[0x138] = .right_alt;
    keycodes[0x11D] = .right_control;
    keycodes[0x036] = .right_shift;
    keycodes[0x15C] = .right_super;
    keycodes[0x150] = .down;
    keycodes[0x14B] = .left;
    keycodes[0x14D] = .right;
    keycodes[0x148] = .up;

    keycodes[0x052] = .kp_0;
    keycodes[0x04F] = .kp_1;
    keycodes[0x050] = .kp_2;
    keycodes[0x051] = .kp_3;
    keycodes[0x04B] = .kp_4;
    keycodes[0x04C] = .kp_5;
    keycodes[0x04D] = .kp_6;
    keycodes[0x047] = .kp_7;
    keycodes[0x048] = .kp_8;
    keycodes[0x049] = .kp_9;
    keycodes[0x04E] = .kp_add;
    keycodes[0x053] = .kp_decimal;
    keycodes[0x135] = .kp_divide;
    keycodes[0x11C] = .kp_enter;
    keycodes[0x059] = .kp_equal;
    keycodes[0x037] = .kp_multiply;
    keycodes[0x04A] = .kp_subtract;

    break :blk keycodes;
};

pub const NativeData = struct {
    kernel32: ZWL.FunctionLoader("Kernel32", &.{
        .{ .name = "GetModuleHandleW", .type = @TypeOf(W32.GetModuleHandleW) },
        .{ .name = "GetLastError", .type = @TypeOf(W32.GetLastError) },
    }),
    user32: ZWL.FunctionLoader("User32", &.{
        .{ .name = "CreateWindowExW", .type = @TypeOf(W32.CreateWindowExW) },
        .{ .name = "DestroyWindow", .type = @TypeOf(W32.DestroyWindow) },
        .{ .name = "DefWindowProcW", .type = @TypeOf(W32.DefWindowProcW) },
        .{ .name = "RegisterClassExW", .type = @TypeOf(W32.RegisterClassExW) },
        .{ .name = "UnregisterClassW", .type = @TypeOf(W32.UnregisterClassW) },
        .{ .name = "LoadCursorW", .type = @TypeOf(W32.LoadCursorW) },
        .{ .name = "GetPropW", .type = @TypeOf(W32.GetPropW) },
        .{ .name = "SetPropW", .type = @TypeOf(W32.SetPropW) },
        .{ .name = "GetActiveWindow", .type = @TypeOf(W32.GetActiveWindow) },
        .{ .name = "PeekMessageW", .type = @TypeOf(W32.PeekMessageW) },
        .{ .name = "TranslateMessage", .type = @TypeOf(W32.TranslateMessage) },
        .{ .name = "DispatchMessageW", .type = @TypeOf(W32.DispatchMessageW) },
        .{ .name = "ClientToScreen", .type = @TypeOf(W32.ClientToScreen) },
        .{ .name = "AdjustWindowRectEx", .type = @TypeOf(W32.AdjustWindowRectEx) },
        .{ .name = "GetClientRect", .type = @TypeOf(W32.GetClientRect) },
        .{ .name = "SetWindowPos", .type = @TypeOf(W32.SetWindowPos) },
        .{ .name = "GetDC", .type = @TypeOf(W32.GetDC) },
        .{ .name = "ShowWindow", .type = @TypeOf(W32.ShowWindow) },
        .{ .name = "SetWindowTextW", .type = @TypeOf(W32.SetWindowTextW) },
        .{ .name = "GetWindowTextLengthW", .type = @TypeOf(W32.GetWindowTextLengthW) },
        .{ .name = "GetWindowTextW", .type = @TypeOf(W32.GetWindowTextW) },
        .{ .name = "GetWindowRect", .type = @TypeOf(W32.GetWindowRect) },
        .{ .name = "MoveWindow", .type = @TypeOf(W32.MoveWindow) },
        .{ .name = "GetCursorPos", .type = @TypeOf(W32.GetCursorPos) },
        .{ .name = "SetCursorPos", .type = @TypeOf(W32.SetCursorPos) },
        .{ .name = "ScreenToClient", .type = @TypeOf(W32.ScreenToClient) },
        .{ .name = "SetCursor", .type = @TypeOf(W32.SetCursor) },
        .{ .name = "ClipCursor", .type = @TypeOf(W32.ClipCursor) },
        .{ .name = "WindowFromPoint", .type = @TypeOf(W32.WindowFromPoint) },
        .{ .name = "PtInRect", .type = @TypeOf(W32.PtInRect) },
        .{ .name = "ShowCursor", .type = @TypeOf(W32.ShowCursor) },
        .{ .name = "GetKeyState", .type = @TypeOf(W32.GetKeyState) },
        .{ .name = "MapVirtualKeyW", .type = @TypeOf(W32.MapVirtualKeyW) },
        .{ .name = "GetMessageTime", .type = @TypeOf(W32.GetMessageTime) },
        .{ .name = "MessageBoxW", .type = @TypeOf(W32.MessageBoxW) },
    }),
    opengl32: ZWL.FunctionLoader("Opengl32", &.{
        .{ .name = "wglCreateContext", .type = @TypeOf(W32.wglCreateContext) },
        .{ .name = "wglDeleteContext", .type = @TypeOf(W32.wglDeleteContext) },
        .{ .name = "wglMakeCurrent", .type = @TypeOf(W32.wglMakeCurrent) },
        .{ .name = "wglGetProcAddress", .type = @TypeOf(W32.wglGetProcAddress) },
        .{ .name = "wglShareLists", .type = @TypeOf(W32.wglShareLists) },
    }),
    gdi32: ZWL.FunctionLoader("Gdi32", &.{
        .{ .name = "SetPixelFormat", .type = @TypeOf(W32.SetPixelFormat) },
        .{ .name = "ChoosePixelFormat", .type = @TypeOf(W32.ChoosePixelFormat) },
        .{ .name = "SwapBuffers", .type = @TypeOf(W32.SwapBuffers) },
    }),
    hInstance: W32.HINSTANCE,
    /// Used to query WGL extensions
    helperWindow: struct {
        handle: W32.HWND,
        dc: W32.HDC,
        glrc: W32.HGLRC,
    },
    wglCreateContextAttribsARB: ?*const fn (hDC: W32.HDC, hShareContext: ?W32.HGLRC, attribList: [*]const i32) callconv(W32.WINAPI) ?W32.HGLRC,
    wglSwapIntervalEXT: ?*const fn (interval: i32) callconv(W32.WINAPI) W32.BOOL,
};

pub inline fn utf8ToUtf16(allocator: Allocator, utf8: []const u8) error{ InvalidUtf8, OutOfMemory }![]const u16 {
    if (@inComptime()) comptime {
        return unicode.utf8ToUtf16LeStringLiteral(utf8);
    } else {
        return unicode.utf8ToUtf16LeAlloc(allocator, utf8);
    }
}

pub inline fn utf8ToUtf16Z(allocator: Allocator, utf8: []const u8) error{ InvalidUtf8, OutOfMemory }![:0]const u16 {
    if (@inComptime()) comptime {
        return unicode.utf8ToUtf16LeStringLiteral(utf8);
    } else {
        return unicode.utf8ToUtf16LeAllocZ(allocator, utf8);
    }
}

pub inline fn utf16ToUtf8(allocator: Allocator, utf16: []const u16) error{ InvalidUtf16, OutOfMemory }![]const u16 {
    return unicode.utf16LeToUtf8Alloc(allocator, utf16) catch error.InvalidUtf16;
}

pub inline fn utf16ToUtf8Z(allocator: Allocator, utf16: []const u16) error{ InvalidUtf16, OutOfMemory }![:0]const u16 {
    return unicode.utf16LeToUtf8AllocZ(allocator, utf16) catch error.InvalidUtf16;
}

pub fn init(lib: *Zwl) Error!void {
    const native = &lib.native;
    native.kernel32.init() catch |e| {
        return lib.setError(
            "Cannot load library \"Kernel32\": {s}",
            .{@errorName(e)},
            error.Win32,
        );
    };
    errdefer native.kernel32.deinit();
    const kernel32 = &native.kernel32.funcs;
    native.user32.init() catch |e| {
        return lib.setError(
            "Cannot load library \"User32\": {s}",
            .{@errorName(e)},
            error.Win32,
        );
    };
    errdefer native.user32.deinit();
    const user32 = &native.user32.funcs;
    native.opengl32.init() catch |e| {
        return lib.setError(
            "Cannot load library \"Opengl32\": {s}",
            .{@errorName(e)},
            error.Win32,
        );
    };
    errdefer native.opengl32.deinit();
    const opengl32 = &native.opengl32.funcs;
    native.gdi32.init() catch |e| {
        return lib.setError(
            "Cannot load library \"Gdi32\": {s}",
            .{@errorName(e)},
            error.Win32,
        );
    };
    errdefer native.gdi32.deinit();
    const gdi32 = &native.gdi32.funcs;

    const hInstance: W32.HINSTANCE = @ptrCast(kernel32.GetModuleHandleW(null));
    native.hInstance = hInstance;

    if (initCount == 0 and user32.RegisterClassExW(&.{
        .style = W32.CS_HREDRAW | W32.CS_VREDRAW | W32.CS_OWNDC,
        .lpfnWndProc = &window.windowProc,
        .hInstance = hInstance,
        .hCursor = user32.LoadCursorW(null, W32.IDC_ARROW),
        .lpszClassName = WND_CLASS_NAME.ptr,
    }) == 0) return lib.setError("Cannot register window class", .{}, Error.Win32);
    initCount += 1;

    const helperWindow = &native.helperWindow;
    event.pollingLib = lib;
    const hWindow = user32.CreateWindowExW(
        0,
        WND_CLASS_NAME.ptr,
        comptime (utf8ToUtf16Z(undefined, "ZWL helper window") catch unreachable).ptr,
        0,
        0,
        0,
        1,
        1,
        null,
        null,
        hInstance,
        null,
    ) orelse {
        return lib.setError("Cannot create helper window", .{}, Error.Win32);
    };
    errdefer _ = user32.DestroyWindow(hWindow);
    _ = user32.ShowWindow(hWindow, W32.SW_HIDE);
    helperWindow.handle = hWindow;

    { // create helper window opengl context
        const dc = user32.GetDC(hWindow) orelse {
            return lib.setError("Cannot get device context from helper window", .{}, Error.Win32);
        };
        helperWindow.dc = dc;

        if (gdi32.SetPixelFormat(dc, gdi32.ChoosePixelFormat(dc, &context.PFD), &context.PFD) == 0) {
            return lib.setError("Cannot set pixel format for device context", .{}, Error.Win32);
        }

        const glrc = opengl32.wglCreateContext(dc) orelse {
            return lib.setError("Cannot create WGL context", .{}, Error.Win32);
        };
        errdefer _ = opengl32.wglDeleteContext(glrc);
        helperWindow.glrc = glrc;

        _ = opengl32.wglMakeCurrent(dc, glrc);

        native.wglCreateContextAttribsARB = @ptrCast(opengl32.wglGetProcAddress("wglCreateContextAttribsARB"));
        native.wglSwapIntervalEXT = @ptrCast(opengl32.wglGetProcAddress("wglSwapIntervalEXT"));

        _ = opengl32.wglMakeCurrent(dc, null);
    }
}

pub fn deinit(lib: *Zwl) void {
    initCount -= 1;
    _ = lib.native.opengl32.funcs.wglDeleteContext(lib.native.helperWindow.glrc);
    _ = lib.native.user32.funcs.DestroyWindow(lib.native.helperWindow.handle);
    if (initCount == 0) {
        _ = lib.native.user32.funcs.UnregisterClassW(WND_CLASS_NAME.ptr, lib.native.hInstance);
    }
    lib.native.kernel32.deinit();
    lib.native.user32.deinit();
    lib.native.opengl32.deinit();
    lib.native.gdi32.deinit();
}
