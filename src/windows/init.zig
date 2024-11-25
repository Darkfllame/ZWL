const std = @import("std");
const Zwl = @import("../zwl.zig");
const W32 = @import("w32.zig");
const window = @import("window.zig");
const event = @import("event.zig");
const context = @import("context.zig");

const unicode = std.unicode;
const Allocator = std.mem.Allocator;

const Platform = Zwl.Platform;
const InitConfig = Zwl.InitConfig;
const Error = Zwl.Error;
const Key = Zwl.Key;

var initCount: u32 = 0;

pub const WND_CLASS_NAME = utf8ToUtf16Z(undefined, "ZWL_WND") catch unreachable;

pub const KEYCODES: [512]Key = blk: {
    var keycodes = [_]Key{.unkown} ** 512;

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
pub const SCANCODES: [@intFromEnum(Key.last)]u16 = blk: {
    var res = [_]u16{0xFFFF} ** @intFromEnum(Key.last);
    for (0..512) |scancode| {
        if (KEYCODES[scancode] != .unkown) {
            res[@intFromEnum(KEYCODES[scancode])] = scancode;
        }
    }
    break :blk res;
};

pub const NativeData = struct {
    hInstance: W32.HINSTANCE,
    /// Used to query WGL extensions
    helperWindow: struct {
        handle: W32.HWND,
        dc: W32.HDC,
        glrc: W32.HGLRC,
    },
    wglCreateContextAttribsARB: ?*const fn (hDC: W32.HDC, hShareContext: ?W32.HGLRC, attribList: [*]const i32) callconv(W32.WINAPI) ?W32.HGLRC,
    wglSwapIntervalEXT: ?*const fn (interval: i32) callconv(W32.WINAPI) W32.BOOL,
    keynames: [@intFromEnum(Key.last)][10:0]u8,
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

pub fn updateKeyNames(native: *NativeData) void {
    var state = [_]u8{0} ** 256;
    @memset(&native.keynames, [_:0]u8{0} ** (@sizeOf(@TypeOf(native.keynames[0])) - 1));
    for (@intFromEnum(Key.space)..@intFromEnum(Key.last)) |key_int| {
        const scancode = SCANCODES[key_int];
        if (scancode == 0xFFFF) continue;

        const vks = [_]W32.UINT{ W32.VK_NUMPAD0, W32.VK_NUMPAD1, W32.VK_NUMPAD2, W32.VK_NUMPAD3, W32.VK_NUMPAD4, W32.VK_NUMPAD5, W32.VK_NUMPAD6, W32.VK_NUMPAD7, W32.VK_NUMPAD8, W32.VK_NUMPAD9, W32.VK_DECIMAL, W32.VK_DIVIDE, W32.VK_MULTIPLY, W32.VK_SUBTRACT, W32.VK_ADD };

        const vk = if (key_int >= @intFromEnum(Key.kp_0) and key_int <= @intFromEnum(Key.kp_add))
            vks[key_int - @intFromEnum(Key.kp_0)]
        else
            W32.MapVirtualKeyW(scancode, W32.MAPVK_VSC_TO_VK);

        var chars: [16]u16 = undefined;
        var length = W32.ToUnicode(
            vk,
            scancode,
            &state,
            @ptrCast(&chars),
            chars.len,
            0,
        );
        if (length == -1) {
            length = W32.ToUnicode(
                vk,
                scancode,
                &state,
                @ptrCast(&chars),
                chars.len + 1,
                0,
            );
        }
        if (length < 1) return;

        const size = std.unicode.utf16LeToUtf8(
            &native.keynames[key_int],
            std.mem.span(@as([*:0]const u16, @ptrCast(&chars))),
        ) catch continue;
        native.keynames[key_int][size] = 0;
    }
}

pub fn init(lib: *Zwl, _: InitConfig) Error!void {
    const native = &lib.native;

    const hInstance: W32.HINSTANCE = @ptrCast(W32.GetModuleHandleW(null));
    native.hInstance = hInstance;

    if (initCount == 0 and W32.RegisterClassExW(&.{
        .style = W32.CS_HREDRAW | W32.CS_VREDRAW | W32.CS_OWNDC,
        .lpfnWndProc = &window.windowProc,
        .hInstance = hInstance,
        .hCursor = W32.LoadCursorW(null, W32.IDC_ARROW),
        .lpszClassName = WND_CLASS_NAME.ptr,
    }) == 0) return lib.setError("Cannot register window class", .{}, Error.Win32);
    initCount += 1;

    const helperWindow = &native.helperWindow;
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

        _ = W32.wglMakeCurrent(dc, glrc);

        native.wglCreateContextAttribsARB = @ptrCast(W32.wglGetProcAddress("wglCreateContextAttribsARB"));
        native.wglSwapIntervalEXT = @ptrCast(W32.wglGetProcAddress("wglSwapIntervalEXT"));

        _ = W32.wglMakeCurrent(dc, null);
    }

    updateKeyNames(native);
}

pub fn deinit(lib: *Zwl) void {
    initCount -= 1;
    _ = W32.wglDeleteContext(lib.native.helperWindow.glrc);
    _ = W32.DestroyWindow(lib.native.helperWindow.handle);
    if (initCount == 0) {
        _ = W32.UnregisterClassW(WND_CLASS_NAME.ptr, lib.native.hInstance);
    }
}

pub fn keyName(lib: *const Zwl, key: Key) [:0]const u8 {
    return std.mem.span(@as([*:0]const u8, @ptrCast(&lib.native.keynames[@intFromEnum(key)])));
}
