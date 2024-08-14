const std = @import("std");
const ZWL = @import("../zwl.zig");
const internal = @import("init.zig");
const W32 = @import("w32.zig");
const event = @import("event.zig");

const assert = std.debug.assert;
const math = std.math;
const clamp = math.clamp;

const Error = ZWL.Error;
const Window = ZWL.Window;
const Zwl = ZWL.Zwl;
const Event = ZWL.Event;
const Key = ZWL.Key;

pub const WND_PTR_PROP_NAME = internal.utf8ToUtf16Z(undefined, "ZWL") catch unreachable;

const MAX_U32 = math.maxInt(u32);

pub const NativeWindow = struct {
    arenaAllocator: std.heap.ArenaAllocator,
    handle: W32.HWND,
    aspectRatio: ?struct {
        numer: u32,
        denom: u32,
    } = null,
    lastMouseX: u16 = 0,
    lastMouseY: u16 = 0,
    keys: [@intFromEnum(Key.menu) + 1]Key.Action = std.mem.zeroes([@intFromEnum(Key.menu) + 1]Key.Action),

    pub fn init(self: *NativeWindow, lib: *Zwl, config: Window.Config) Error!void {
        const window: *Window = @fieldParentPtr("native", self);
        self.* = .{
            .arenaAllocator = std.heap.ArenaAllocator.init(lib.allocator),
            .handle = undefined,
        };
        defer _ = self.arenaAllocator.reset(.free_all);
        const arena = self.arenaAllocator.allocator();

        const title_copy = window.owner.allocator.dupe(u8, config.title) catch |e| {
            return lib.setError("Cannot copy window title", .{}, e);
        };
        errdefer window.owner.allocator.free(title_copy);
        window.config.title = title_copy;

        const wideTitle = internal.utf8ToUtf16Z(arena, config.title) catch |e| {
            return lib.setError("Cannot create wide title for Win32", .{}, e);
        };

        const sizeLimits = config.sizeLimits;
        const style = windowFlagsToNative(blk: {
            var flags = config.flags;
            if (!flags.no_decoration and
                sizeLimits.wmin != null and sizeLimits.wmax != null and
                sizeLimits.hmin != null and sizeLimits.hmax != null and
                sizeLimits.wmin == sizeLimits.wmax and
                sizeLimits.hmin == sizeLimits.hmax)
            {
                flags.resizable = false;
            }
            break :blk flags;
        });

        const handle = W32.CreateWindowExW(
            0,
            internal.WND_CLASS_NAME.ptr,
            wideTitle.ptr,
            style,
            @bitCast(config.x.toNumber(@bitCast(W32.CW_USEDEFAULT))),
            @bitCast(config.y.toNumber(@bitCast(W32.CW_USEDEFAULT))),
            @bitCast(config.width),
            @bitCast(config.height),
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

        window.setMouseVisible(!config.flags.hide_mouse);
    }

    pub fn deinit(self: *NativeWindow) void {
        const window: *Window = @fieldParentPtr("native", self);
        window.owner.allocator.free(window.config.title);
        self.arenaAllocator.deinit();
        _ = W32.DestroyWindow(self.handle);
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
            .left = x,
            .top = y,
            .right = x,
            .bottom = y,
        };
        _ = W32.AdjustWindowRectEx(
            &rect,
            windowFlagsToNative(window.flags),
            W32.FALSE,
            windowFlagsToExNative(window.flags),
        );

        _ = W32.SetWindowPos(
            window.native.handle,
            null,
            rect.bottom,
            rect.top,
            0,
            0,
            W32.SWP_NOACTIVE | W32.SWP_NOZORDER | W32.SWP_NOSIZE,
        );
    }

    pub fn getSize(window: *Window, w: ?*u32, h: ?*u32) void {
        var area: W32.RECT = .{};
        _ = W32.GetClientRect(window.native.handle, &area);

        {
            @setRuntimeSafety(false);
            if (w) |_| w.?.* = @bitCast(area.right);
            if (h) |_| h.?.* = @bitCast(area.bottom);
        }
    }

    pub fn setSize(window: *Window, w: u32, h: u32) void {
        const sl = window.config.sizeLimits;
        const width = clamp(
            w,
            sl.wmin orelse 0,
            sl.wmax orelse MAX_U32,
        );
        const height = clamp(
            h,
            sl.wmin orelse 0,
            sl.wmax orelse MAX_U32,
        );

        var rect = W32.RECT{
            .left = 0,
            .top = 0,
            .right = @bitCast(width),
            .bottom = @bitCast(height),
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
        assert((wmin orelse 0) < (wmax orelse MAX_U32));
        assert((hmin orelse 0) < (hmax orelse MAX_U32));

        window.config.sizeLimits = .{
            .wmin = wmin,
            .wmax = wmax,
            .hmin = hmin,
            .hmax = hmax,
        };

        if (!window.config.flags.resizable) {
            return;
        }

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
            area.right - area.left,
            area.bottom - area.top,
            W32.TRUE,
        );
    }

    pub const getFramebufferSize = getSize;

    pub fn setVisible(window: *Window, value: bool) void {
        _ = W32.ShowWindow(window.native.handle, W32.SW_SHOWNA * @intFromBool(value));
    }

    pub fn setTitle(window: *Window, title: []const u8) Error!void {
        defer _ = window.native.arenaAllocator.reset(.free_all);
        const arena = window.native.arenaAllocator.allocator();

        const wideTitle = internal.utf8ToUtf16Z(arena, title) catch |e| {
            return window.owner.setError("Cannot create wide title for Win32", .{}, e);
        };

        _ = W32.SetWindowTextW(window.native.handle, wideTitle.ptr);

        const title_copy = window.owner.allocator.dupe(u8, title) catch |e| {
            return window.owner.setError("Cannot copy window title", .{}, e);
        };
        window.owner.allocator.free(window.config.title);
        window.config.title = title_copy;
    }

    /// The returned string is allocated via the allocator
    /// given to `Zwl.init()`.
    pub fn getTitle(window: *Window) []const u8 {
        return window.config.title;
    }

    pub fn isFocused(window: *Window) bool {
        return window.native.handle == W32.GetActiveWindow();
    }

    pub fn getMousePos(window: *Window, x: ?*u32, y: ?*u32) void {
        var pos: W32.POINT = undefined;
        if (W32.GetCursorPos(&pos) != 0) {
            _ = W32.ScreenToClient(window.native.handle, &pos);

            {
                @setRuntimeSafety(false);
                if (x) |_| x.?.* = @bitCast(pos.x);
                if (y) |_| y.?.* = @bitCast(pos.y);
            }
        }
    }

    pub fn setMousePos(window: *Window, x: u32, y: u32) void {
        if (window.native.lastMouseX == x and window.native.lastMouseY == y) {
            return;
        }
        var pos: W32.POINT = .{ .x = @bitCast(x), .y = @bitCast(y) };
        window.native.lastMouseX = @intCast(x);
        window.native.lastMouseX = @intCast(y);
        _ = W32.ClientToScreen(window.native.handle, &pos);
        _ = W32.SetCursorPos(pos.x, pos.y);
    }

    pub fn setMouseVisible(window: *Window, value: bool) void {
        _ = window;
        _ = W32.ShowCursor(@intFromBool(value));
    }
};

pub fn windowProc(wind: W32.HWND, msg: W32.UINT, wp: W32.WPARAM, lp: W32.LPARAM) callconv(W32.CALLBACK) W32.LRESULT {
    const window: *Window = @ptrCast(@alignCast(W32.GetPropW(wind, WND_PTR_PROP_NAME.ptr) orelse {
        return W32.DefWindowProcW(wind, msg, wp, lp);
    }));

    switch (msg) {
        W32.WM_CLOSE => {
            event.polledEvent = Event{ .windowClosed = window };
        },
        W32.WM_SIZE => {
            event.polledEvent = Event{ .windowResized = .{
                .window = window,
                .width = @truncate(@as(u64, @bitCast(lp)) & 0xFFFF),
                .height = @truncate(@as(u64, @bitCast(lp >> 16)) & 0xFFFF),
            } };
        },
        W32.WM_MOUSEMOVE => {
            const x: u16 = @truncate(@as(u64, @bitCast(lp)) & 0xFFFF);
            const y: u16 = @truncate(@as(u64, @bitCast(lp >> 16)) & 0xFFFF);

            const dx = @as(i16, @bitCast(x)) - @as(i16, @bitCast(window.native.lastMouseX));
            const dy = @as(i16, @bitCast(y)) - @as(i16, @bitCast(window.native.lastMouseY));
            event.polledEvent = Event{ .mouseMoved = .{
                .window = window,
                .x = x,
                .y = y,
                .dx = dx,
                .dy = dy,
            } };

            window.native.lastMouseX = x;
            window.native.lastMouseY = y;
        },
        W32.WM_SIZING => {
            const rect: *W32.RECT = @ptrFromInt(@as(u64, @bitCast(lp)));
            applyWindowConstraints(&window.config, wp, rect);
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

            if (sl.wmax != null and sl.hmax != null) {
                @setRuntimeSafety(false);
                mmi.ptMinTrackSize.x = @bitCast(sl.wmin.? + xoff);
                mmi.ptMinTrackSize.y = @bitCast(sl.hmin.? + yoff);
            }

            if (sl.wmax != null and sl.hmax != null) {
                @setRuntimeSafety(false);
                mmi.ptMaxTrackSize.x = @bitCast(sl.wmax.? + xoff);
                mmi.ptMaxTrackSize.y = @bitCast(sl.hmax.? + yoff);
            }
        },
        W32.WM_KEYDOWN, W32.WM_KEYUP, W32.WM_SYSKEYDOWN, W32.WM_SYSKEYUP => blk: {
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

            //  wp == VK_CONTROL
            if (wp == 0x11) {
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
            } else if (wp == 0xE5) {
                break :blk;
            }

            var repeated: bool = false;

            if (action == .release and window.native.keys[@intFromEnum(key)] == .release) {
                break :blk;
            }

            if (action == .press and window.native.keys[@intFromEnum(key)] == .press) {
                repeated = true;
            }

            window.native.keys[@intFromEnum(key)] = action;

            //                               VK_SHIFT
            if (action == .release and wp == 0x10) {
                if (repeated)
                    action = .repeat;
                event.polledEvent = Event{ .key = .{
                    .window = window,
                    .key = .left_shift,
                    .action = action,
                    .mods = mods,
                } };
                event.polledEvent2 = Event{ .key = .{
                    .window = window,
                    .key = .right_shift,
                    .action = action,
                    .mods = mods,
                } };
                //           VK_SNAPSHOT
            } else if (wp == 0x2C) {
                if (repeated)
                    action = .repeat;
                event.polledEvent = Event{ .key = .{
                    .window = window,
                    .key = key,
                    .action = .press,
                    .mods = mods,
                } };
                event.polledEvent2 = Event{ .key = .{
                    .window = window,
                    .key = key,
                    .action = .release,
                    .mods = mods,
                } };
            } else {
                if (repeated)
                    action = .repeat;
                event.polledEvent = Event{ .key = .{
                    .window = window,
                    .key = key,
                    .action = action,
                    .mods = mods,
                } };
            }
        },
        else => {},
    }

    return W32.DefWindowProcW(wind, msg, wp, lp);
}

fn applyWindowConstraints(config: *const Window.Config, edge: W32.WPARAM, rect: *W32.RECT) void {
    _ = config;
    _ = edge;
    _ = rect;
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
        .right = @bitCast(contentWidth),
        .bottom = @bitCast(contentHeight),
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

    if (flags.no_decoration) {
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
