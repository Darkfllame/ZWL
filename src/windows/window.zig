const std = @import("std");
const Zwl = @import("../Zwl.zig");
const internal = @import("init.zig");
const W32 = @import("w32.zig");
const event = @import("event.zig");

const assert = std.debug.assert;
const math = std.math;
const clamp = math.clamp;

const Error = Zwl.Error;
const Window = Zwl.Window;
const Event = Zwl.Event;
const Key = Zwl.Key;

pub const WND_PTR_PROP_NAME = internal.utf8ToUtf16Z(undefined, "ZWL") catch unreachable;

const MAX_U32 = math.maxInt(u32);

pub const NativeWindow = struct {
    handle: W32.HWND,
    dc: W32.HDC,

    var barSizeSet = false;
    var barW: i32 = 0;
    var barH: i32 = 0;

    pub fn init(self: *NativeWindow, lib: *Zwl, config: Window.Config) Error!void {
        const window: *Window = @fieldParentPtr("native", self);
        var aa = std.heap.ArenaAllocator.init(window.owner.allocator);
        defer _ = aa.reset(.free_all);
        const arena = aa.allocator();

        const wideTitle = internal.utf8ToUtf16Z(arena, config.title) catch |e| {
            return lib.setError("Cannot create wide title for Win32", .{}, e);
        };

        const sizeLimits = config.sizeLimits;
        const style = windowFlagsToNative(blk: {
            var flags = config.flags;
            if (!flags.noDecoration and
                sizeLimits.wmin != null and sizeLimits.wmax != null and
                sizeLimits.hmin != null and sizeLimits.hmax != null and
                sizeLimits.wmin == sizeLimits.wmax and
                sizeLimits.hmin == sizeLimits.hmax)
            {
                flags.resizable = false;
            }
            break :blk flags;
        });

        if (!barSizeSet) {
            barW = W32.GetSystemMetrics(W32.SM_CXSIZEFRAME) +
                W32.GetSystemMetrics(W32.SM_CXEDGE) * 2 + 8;
            barH = W32.GetSystemMetrics(W32.SM_CYCAPTION) +
                W32.GetSystemMetrics(W32.SM_CYSIZEFRAME) +
                W32.GetSystemMetrics(W32.SM_CYEDGE) * 2 + 8;
            barSizeSet = true;
        }

        const handle = W32.CreateWindowExW(
            0,
            internal.WND_CLASS_NAME.ptr,
            wideTitle.ptr,
            style,
            @bitCast(config.x.toNumber(@bitCast(W32.CW_USEDEFAULT))),
            @bitCast(config.y.toNumber(@bitCast(W32.CW_USEDEFAULT))),
            @as(i32, @intCast(config.width)) + barW,
            @as(i32, @intCast(config.height)) + barH,
            null,
            null,
            lib.native.hInstance,
            null,
        ) orelse {
            return lib.setError("Cannot create window", .{}, Error.Win32);
        };
        errdefer _ = W32.DestroyWindow(handle);

        if (W32.SetPropW(handle, WND_PTR_PROP_NAME.ptr, @ptrCast(window)) == 0) {
            return lib.setError("Cannot set window property", .{}, Error.Win32);
        }

        self.handle = handle;
        self.dc = W32.GetDC(handle) orelse {
            return lib.setError("Cannot retreive window's device context", .{}, Error.Win32);
        };

        window.setMouseVisible(!config.flags.hideMouse);
    }

    pub fn deinit(self: *NativeWindow) void {
        _ = W32.ReleaseDC(self.handle, self.dc);
        _ = W32.DestroyWindow(self.handle);
    }

    pub fn createMessageBox(lib: *Zwl, config: Window.MBConfig) Error!Window.MBButton {
        const wideTitle = internal.utf8ToUtf16Z(lib.allocator, config.title) catch |e| {
            return lib.setError("Cannot create wide title for Win32", .{}, e);
        };
        defer lib.allocator.free(wideTitle);
        const wideText = internal.utf8ToUtf16Z(lib.allocator, config.text) catch |e| {
            return lib.setError("Cannot create wide text for Win32", .{}, e);
        };
        defer lib.allocator.free(wideText);

        var uType: W32.UINT = 0;
        uType |= switch (config.mode) {
            .ok => 0,
            .okCancel => 1,
            .abortRetryIgnore => 2,
            .yesNoCancel => 3,
            .yesNo => 4,
            .retryCancel => 5,
            .cancelTryContinue => 6,
        };
        uType |= switch (config.icon) {
            .none => 0,
            .@"error" => 0x10,
            .question => 0x20,
            .warning => 0x30,
            .information => 0x40,
        };

        const ret = W32.MessageBoxW(
            if (config.parent) |p| p.native.handle else null,
            wideText.ptr,
            wideTitle.ptr,
            uType,
        );
        return switch (ret) {
            0 => lib.setError("Cannot create message box", .{}, Error.Win32),
            1 => .ok,
            2 => .cancel,
            3 => .abort,
            4 => .retry,
            5 => .ignore,
            6 => .yes,
            7 => .no,
            11 => .@"continue",
            10 => .tryAgain,
            else => unreachable,
        };
    }

    pub fn getPosition(window: *Window, x: ?*u32, y: ?*u32) void {
        var pt: W32.POINT = .{};
        _ = W32.ClientToScreen(window.native.handle, &pt);

        {
            @setRuntimeSafety(false);
            if (x) |_| x.?.* = @bitCast(pt.x);
            if (y) |_| y.?.* = @bitCast(pt.y);
        }
    }

    pub fn setPosition(window: *Window, x: u32, y: u32) void {
        window.config.x = .{ .pos = x };
        window.config.y = .{ .pos = y };

        var rect = W32.RECT{
            .left = @bitCast(x),
            .top = @bitCast(y),
            .right = @bitCast(x),
            .bottom = @bitCast(y),
        };
        _ = W32.AdjustWindowRectEx(
            &rect,
            windowFlagsToNative(window.config.flags),
            W32.FALSE,
            windowFlagsToExNative(window.config.flags),
        );

        _ = W32.SetWindowPos(
            window.native.handle,
            null,
            rect.bottom,
            rect.top,
            0,
            0,
            W32.SWP_NOACTIVATE | W32.SWP_NOZORDER | W32.SWP_NOSIZE,
        );
    }

    pub fn setSize(window: *Window, w: u32, h: u32) void {
        var rect = W32.RECT{
            .left = 0,
            .top = 0,
            .right = @as(i32, @intCast(w)) + barW,
            .bottom = @as(i32, @intCast(h)) + barH,
        };

        _ = W32.AdjustWindowRectEx(
            &rect,
            windowFlagsToNative(window.config.flags),
            W32.FALSE,
            windowFlagsToExNative(window.config.flags),
        );

        _ = W32.SetWindowPos(
            window.native.handle,
            W32.HWND_TOP,
            0,
            0,
            rect.right - rect.left,
            rect.bottom - rect.top,
            W32.SWP_NOACTIVATE | W32.SWP_NOOWNERZORDER | W32.SWP_NOMOVE | W32.SWP_NOZORDER,
        );
    }

    pub fn setSizeLimits(
        window: *Window,
        wmin: ?u32,
        wmax: ?u32,
        hmin: ?u32,
        hmax: ?u32,
    ) void {
        if ((wmin == null and hmin == null) and
            (wmax == null or hmax == null))
        {
            return;
        }

        var area: W32.RECT = undefined;

        _ = W32.GetWindowRect(window.native.handle, &area);
        _ = W32.MoveWindow(
            window.native.handle,
            area.left,
            area.top,
            area.right - area.left + barW,
            area.bottom - area.top + barH,
            W32.TRUE,
        );
    }

    pub fn getFramebufferSize(window: *Window, w: ?*u32, h: ?*u32) void {
        var area: W32.RECT = .{};
        _ = W32.GetClientRect(window.native.handle, &area);

        {
            @setRuntimeSafety(false);
            if (w) |_| w.?.* = @bitCast(area.right);
            if (h) |_| h.?.* = @bitCast(area.bottom);
        }
    }

    pub fn setVisible(window: *Window, value: bool) void {
        _ = W32.ShowWindow(window.native.handle, W32.SW_SHOWNA * @intFromBool(value));
    }

    pub fn setTitle(window: *Window, title: []const u8) Error!void {
        const wideTitle = internal.utf8ToUtf16Z(window.owner.allocator, title) catch |e| {
            return window.owner.setError("Cannot create wide title for Win32", .{}, e);
        };
        defer window.owner.allocator.free(wideTitle);

        _ = W32.SetWindowTextW(window.native.handle, wideTitle.ptr);
    }

    pub fn isFocused(window: *Window) bool {
        return window.native.handle == W32.GetActiveWindow();
    }

    pub fn getMousePos(window: *Window, x: ?*u32, y: ?*u32) void {
        var pos: W32.POINT = undefined;
        if (W32.GetCursorPos(&pos) != 0) {
            _ = W32.ScreenToClient(window.native.handle, &pos);

            if (x) |xp| xp.* = @bitCast(pos.x);
            if (y) |yp| yp.* = @bitCast(pos.y);
        }
    }

    pub fn setMousePos(window: *Window, x: u32, y: u32) void {
        var pos: W32.POINT = .{ .x = @bitCast(x), .y = @bitCast(y) };
        _ = W32.ClientToScreen(window.native.handle, &pos);
        _ = W32.SetCursorPos(pos.x, pos.y);
    }

    pub fn setMouseVisible(window: *Window, value: bool) void {
        _ = window;
        _ = W32.ShowCursor(@intFromBool(value));
    }

    pub fn setFocus(window: *Window) void {
        _ = W32.SetFocus(window.native.handle);
    }

    pub fn setMouseConfined(window: *Window, value: bool) void {
        if (value) {
            var rect: W32.RECT = .{
                .right = @intCast(window.config.width),
                .bottom = @intCast(window.config.height),
            };
            _ = W32.ClientToScreen(window.native.handle, @ptrCast(&rect));
            _ = W32.ClientToScreen(window.native.handle, @ptrCast(&rect.right));
            _ = W32.ClipCursor(&rect);
        } else {
            _ = W32.ClipCursor(null);
        }
    }

    pub fn freeMouse(window: *Window) void {
        _ = window;
        _ = W32.ClipCursor(null);
    }

    pub fn getDC(window: *NativeWindow) ?W32.HDC {
        return W32.GetDC(window.handle);
    }
};

pub fn windowProc(wind: W32.HWND, msg: W32.UINT, wp: W32.WPARAM, lp: W32.LPARAM) callconv(W32.CALLBACK) W32.LRESULT {
    const window: *Window = @ptrCast(@alignCast(W32.GetPropW(wind, WND_PTR_PROP_NAME.ptr) orelse {
        return W32.DefWindowProcW(wind, msg, wp, lp);
    }));

    return windowProcInner(wind, window, msg, wp, lp) catch |e| blk: {
        event.pollingError = e;
        break :blk 1;
    };
}

fn windowProcInner(wind: W32.HWND, window: *Window, msg: W32.UINT, wp: W32.WPARAM, lp: W32.LPARAM) Error!W32.LRESULT {
    const lib = window.owner;

    switch (msg) {
        W32.WM_CLOSE => {
            try event.queueEvent(lib, .{ .windowClosed = window });
        },
        W32.WM_SIZE => {
            const width: u16 = @truncate(@as(u64, @bitCast(lp)) & 0xFFFF);
            const height: u16 = @truncate(@as(u64, @bitCast(lp >> 16)) & 0xFFFF);
            try event.queueEvent(lib, .{ .windowResized = .{
                .window = window,
                .width = width,
                .height = height,
            } });
            window.config.width = width;
            window.config.height = height;
        },
        W32.WM_MOUSEMOVE => {
            const x: u16 = @truncate(@as(u64, @bitCast(lp)) & 0xFFFF);
            const y: u16 = @truncate(@as(u64, @bitCast(lp >> 16)) & 0xFFFF);

            const dx = @as(i16, @bitCast(x)) - @as(i16, @bitCast(window.mouse.lastX));
            const dy = @as(i16, @bitCast(y)) - @as(i16, @bitCast(window.mouse.lastY));
            try event.queueEvent(lib, .{ .mouseMoved = .{
                .window = window,
                .x = x,
                .y = y,
                .dx = dx,
                .dy = dy,
            } });

            window.mouse.lastX = x;
            window.mouse.lastY = y;
        },
        W32.WM_LBUTTONDOWN,
        W32.WM_LBUTTONUP,
        W32.WM_RBUTTONDOWN,
        W32.WM_RBUTTONUP,
        W32.WM_MBUTTONDOWN,
        W32.WM_MBUTTONUP,
        W32.WM_XBUTTONDOWN,
        W32.WM_XBUTTONUP,
        => {
            const button: u8 = switch (msg) {
                W32.WM_LBUTTONDOWN, W32.WM_LBUTTONUP => 0,
                W32.WM_RBUTTONDOWN, W32.WM_RBUTTONUP => 2,
                W32.WM_MBUTTONDOWN, W32.WM_MBUTTONUP => 1,
                W32.WM_XBUTTONDOWN, W32.WM_XBUTTONUP => @truncate(((wp >> 16) & 0xFFFF) + 2),
                else => unreachable,
            };
            const pressed: bool = switch (msg) {
                W32.WM_LBUTTONDOWN, W32.WM_RBUTTONDOWN, W32.WM_MBUTTONDOWN, W32.WM_XBUTTONDOWN => true,
                W32.WM_LBUTTONUP, W32.WM_RBUTTONUP, W32.WM_MBUTTONUP, W32.WM_XBUTTONUP => false,
                else => unreachable,
            };
            const mods = getKeyMods();
            window.mouseButtons[button] = pressed;
            try event.queueEvent(lib, .{ .mouseButton = .{
                .window = window,
                .clicked = pressed,
                .button = button,
                .mods = .{
                    .control = mods.control,
                    .shift = mods.shift,
                },
            } });
        },
        W32.WM_MOUSEWHEEL => {
            try event.queueEvent(lib, .{ .mouseWheel = .{
                .window = window,
                .x = 0,
                .y = @as(f32, @floatFromInt((wp >> 16) & 0xFFFF)) / 120,
                .mods = .{
                    .control = wp & 0x08 != 0,
                    .shift = wp & 0x04 != 0,
                },
            } });
        },
        W32.WM_MOUSEHWHEEL => {
            try event.queueEvent(lib, .{ .mouseWheel = .{
                .window = window,
                .x = @as(f32, @floatFromInt((wp >> 16) & 0xFFFF)) / 120,
                .y = 0,
                .mods = .{
                    .control = wp & 0x08 != 0,
                    .shift = wp & 0x04 != 0,
                },
            } });
        },
        W32.WM_GETMINMAXINFO => {
            if (!window.config.flags.resizable) {
                return 0;
            }

            const mmi: *W32.MINMAXINFO = @ptrFromInt(@as(u64, @bitCast(lp)));
            const config = window.config;
            const sl = config.sizeLimits;

            var xoff: u32 = undefined;
            var yoff: u32 = undefined;
            //                  USER_DEFAULT_SCREEN_DPI
            const dpi: W32.UINT = 96;

            getWindowFullsize(
                windowFlagsToNative(window.config.flags),
                windowFlagsToExNative(window.config.flags),
                0,
                0,
                &xoff,
                &yoff,
                dpi,
            );

            if (sl.wmin) |wmin| {
                mmi.ptMinTrackSize.x = @bitCast(wmin + xoff);
            }
            if (sl.wmax) |wmax| {
                mmi.ptMinTrackSize.x = @bitCast(wmax + xoff);
            }
            if (sl.hmin) |hmin| {
                mmi.ptMinTrackSize.y = @bitCast(hmin + yoff);
            }
            if (sl.hmax) |hmax| {
                mmi.ptMinTrackSize.y = @bitCast(hmax + yoff);
            }
        },
        W32.WM_KEYDOWN,
        W32.WM_KEYUP,
        W32.WM_SYSKEYDOWN,
        W32.WM_SYSKEYUP,
        => blk: {
            const lp_hiword = @as(u64, @bitCast(lp >> 16)) & 0xFFFF;

            var scancode: u32 = @truncate(lp_hiword & 0x01FF);
            var action: Key.Action = if (lp_hiword & 0x8000 != 0)
                .release
            else
                .press;
            const mods = getKeyMods();

            if (scancode == 0) {
                scancode = @bitCast(W32.MapVirtualKeyW(@truncate(wp), 0));
            }

            scancode = switch (scancode) {
                0x54 => 0x137,
                0x146 => 0x45,
                0x136 => 0x36,
                else => scancode,
            };

            var key = internal.KEYCODES[scancode];

            if (wp == W32.VK_CONTROL) {
                if (lp_hiword & 0x0100 != 0) {
                    key = .right_control;
                } else {
                    var next: W32.MSG = undefined;
                    const time = W32.GetMessageTime();

                    if (W32.PeekMessageW(&next, null, 0, 0, W32.PM_NOREMOVE) != 0) {
                        if (next.message == W32.WM_KEYDOWN or
                            next.message == W32.WM_SYSKEYDOWN or
                            next.message == W32.WM_KEYUP or
                            next.message == W32.WM_SYSKEYUP)
                        {
                            if (next.wParam == 0x12 and
                                @as(u64, @bitCast(next.lParam >> 16)) & 0x0100 != 0 and
                                next.time == time)
                            {
                                break :blk;
                            }
                        }
                    }

                    key = .left_control;
                }
            } else if (wp == W32.VK_PROCESSKEY) {
                break :blk;
            }

            var repeated: bool = false;

            if (action == .release and !window.keys[@intFromEnum(key)]) {
                break :blk;
            }

            if (action == .press and window.keys[@intFromEnum(key)]) {
                repeated = true;
            }

            window.keys[@intFromEnum(key)] = action == .press;

            if (repeated)
                action = .repeat;
            if (action == .release and wp == W32.VK_SHIFT) {
                try event.queueEvent(lib, .{ .key = .{
                    .window = window,
                    .key = .left_shift,
                    .action = action,
                    .mods = mods,
                } });
                try event.queueEvent(lib, .{ .key = .{
                    .window = window,
                    .key = .right_shift,
                    .action = action,
                    .mods = mods,
                } });
            } else if (wp == W32.VK_SNAPSHOT) {
                try event.queueEvent(lib, .{ .key = .{
                    .window = window,
                    .key = key,
                    .action = .press,
                    .mods = mods,
                } });
                try event.queueEvent(lib, .{ .key = .{
                    .window = window,
                    .key = key,
                    .action = .release,
                    .mods = mods,
                } });
            } else {
                try event.queueEvent(lib, .{ .key = .{
                    .window = window,
                    .key = key,
                    .action = action,
                    .mods = mods,
                } });
            }
        },
        W32.WM_SETFOCUS, W32.WM_KILLFOCUS => {
            const status = msg == W32.WM_SETFOCUS;
            window.config.flags.hasFocus = status;
            try event.queueEvent(lib, .{ .windowFocused = .{
                .window = window,
                .gained = status,
            } });
        },
        W32.WM_INPUTLANGCHANGE => {
            internal.updateKeyNames(&lib.native);
        },
        else => {},
    }

    return W32.DefWindowProcW(wind, msg, wp, lp);
}
fn getWindowFullsize(
    style: W32.DWORD,
    exStyle: W32.DWORD,
    contentWidth: u32,
    contentHeight: u32,
    fullWidth: *u32,
    fullHeight: *u32,
    dpi: W32.UINT,
) void {
    _ = dpi;
    var rect: W32.RECT = .{
        .left = 0,
        .top = 0,
        .right = @intCast(contentWidth),
        .bottom = @intCast(contentHeight),
    };

    _ = W32.AdjustWindowRectEx(&rect, style, W32.FALSE, exStyle);

    fullWidth.* = @bitCast(rect.right - rect.left);
    fullHeight.* = @bitCast(rect.bottom - rect.top);
}

pub fn getKeyMods() Key.Mods {
    var mods: Key.Mods = .{};

    if (W32.GetKeyState(0x10) & 0x8000 != 0)
        mods.shift = true;
    if (W32.GetKeyState(0x11) & 0x8000 != 0)
        mods.control = true;
    if (W32.GetKeyState(0x12) & 0x8000 != 0)
        mods.alt = true;
    if (W32.GetKeyState(0x5B) & 0x8000 != 0 and
        W32.GetKeyState(0x5C) & 0x8000 != 0)
        mods.super = true;
    if (W32.GetKeyState(0x14) & 1 != 0)
        mods.capsLock = true;
    if (W32.GetKeyState(0x90) & 1 != 0)
        mods.numLock = true;

    return mods;
}

fn windowFlagsToNative(flags: Window.Flags) W32.DWORD {
    var style = W32.WS_CLIPSIBLINGS | W32.WS_CLIPCHILDREN;

    if (!flags.hidden) {
        style |= W32.WS_VISIBLE;
    }

    style |= W32.WS_SYSMENU | W32.WS_MINIMIZEBOX;

    if (flags.noDecoration) {
        style |= W32.WS_POPUP;
    } else {
        style |= W32.WS_CAPTION;

        if (flags.resizable) {
            style |= W32.WS_MAXIMIZEBOX | W32.WS_THICKFRAME;
        }
    }

    return style;
}

fn windowFlagsToExNative(flags: Window.Flags) W32.DWORD {
    var style = W32.WS_EX_APPWINDOW;

    if (flags.floating) {
        style |= W32.WS_EX_TOPMOST;
    }

    return style;
}
