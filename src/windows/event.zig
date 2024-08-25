const std = @import("std");
const ZWL = @import("../zwl.zig");
const W32 = @import("w32.zig");
const window = @import("window.zig");

const Window = ZWL.Window;
const Error = ZWL.Error;
const Event = ZWL.Event;
const Zwl = ZWL.Zwl;
const Key = ZWL.Key;

pub var polledEvent: ?Event = null;
pub var polledEvent2: ?Event = null;

pub fn pollEvent(lib: *Zwl, opt_window: ?*Window) Error!?Event {
    _ = lib;
    if (polledEvent2) |pe2| {
        polledEvent2 = null;
        return pe2;
    }
    polledEvent = null;

    var msg: W32.MSG = undefined;

    if (W32.PeekMessageW(
        &msg,
        if (opt_window) |wnd| wnd.native.handle else null,
        0,
        0,
        W32.PM_REMOVE,
    ) != 0) {
        switch (msg.message) {
            W32.WM_QUIT => return .{ .quit = msg.wParam },
            else => {
                _ = W32.TranslateMessage(&msg);
                _ = W32.DispatchMessageW(&msg);
                return polledEvent;
            },
        }
    }

    if (W32.GetActiveWindow()) |handle| {
        if (@as(?*Window, @ptrCast(@alignCast(W32.GetPropW(handle, window.WND_PTR_PROP_NAME.ptr))))) |wnd| {
            const keys = [_]struct { u8, Key }{
                .{ 0xA0, .left_shift },
                .{ 0xA1, .right_shift },
                .{ 0x5B, .left_super },
                .{ 0x5C, .right_super },
            };

            for (keys) |keypair| {
                const vk = keypair[0];
                const key = keypair[1];

                if (W32.GetKeyState(vk) & 0x8000 != 0) {
                    continue;
                }
                if (wnd.keys[@intFromEnum(key)] != .press) {
                    continue;
                }

                return Event{ .key = .{
                    .window = wnd,
                    .key = key,
                    .action = .release,
                    .mods = window.getKeyMods(),
                } };
            }
        }
    }

    return null;
}
