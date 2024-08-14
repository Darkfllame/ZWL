const std = @import("std");
const ZWL = @import("../zwl.zig");
const W32 = @import("w32.zig");
const window = @import("window.zig");
const context = @import("context.zig");

const unicode = std.unicode;
const Allocator = std.mem.Allocator;

const Error = ZWL.Error;
const Zwl = ZWL.Zwl;

pub const WND_CLASS_NAME = utf8ToUtf16Z(undefined, "ZWL_WND") catch unreachable;

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

pub const NativeData = struct {
    hInstance: W32.HINSTANCE,
    /// Used to query WGL extensions
    helperWindow: struct {
        handle: W32.HWND,
        dc: W32.HDC,
        glrc: W32.HGLRC,
    },
};

pub const KEYCODES: [512]ZWL.Key = blk: {
    var keycodes = std.mem.zeroes([512]ZWL.Key);

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

pub fn init(lib: *Zwl) Error!void {
    const hInstance: W32.HINSTANCE = @ptrCast(W32.GetModuleHandleW(null));
    lib.native.hInstance = hInstance;

    if (W32.RegisterClassExW(&.{
        .style = W32.CS_HREDRAW | W32.CS_VREDRAW | W32.CS_OWNDC,
        .lpfnWndProc = &window.windowProc,
        .hInstance = hInstance,
        .hCursor = W32.LoadCursorW(null, W32.IDC_ARROW),
        .lpszClassName = WND_CLASS_NAME.ptr,
    }) == 0) return lib.setError("Cannot register window class", .{}, Error.Win32);

    const helperWindow = &lib.native.helperWindow;
    const hWindow = W32.CreateWindowExW(
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
    errdefer _ = W32.DestroyWindow(hWindow);
    _ = W32.ShowWindow(hWindow, W32.SW_HIDE);
    helperWindow.handle = hWindow;

    { // create helper window opengl context
        const dc = W32.GetDC(hWindow) orelse {
            return lib.setError("Cannot get device context from helper window", .{}, Error.Win32);
        };
        helperWindow.dc = dc;

        if (W32.SetPixelFormat(dc, W32.ChoosePixelFormat(dc, &context.PFD), &context.PFD) == 0) {
            return lib.setError("Cannot set pixel format for device context", .{}, Error.Win32);
        }

        const glrc = W32.wglCreateContext(dc) orelse {
            return lib.setError("Cannot create WGL context", .{}, Error.Win32);
        };
        errdefer _ = W32.wglDeleteContext(glrc);
        helperWindow.glrc = glrc;
    }
}
pub fn deinit(lib: *Zwl) void {
    _ = W32.wglDeleteContext(lib.native.helperWindow.glrc);
    _ = W32.DestroyWindow(lib.native.helperWindow.handle);
    _ = W32.UnregisterClassW(WND_CLASS_NAME.ptr, lib.native.hInstance);
}
