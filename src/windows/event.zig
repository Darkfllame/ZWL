const std = @import("std");
const Zwl = @import("../Zwl.zig");
const W32 = @import("w32.zig");
const window = @import("window.zig");
const event = @import("../event.zig");

const Window = Zwl.Window;
const Error = Zwl.Error;
const Event = Zwl.Event;
const Key = Zwl.Key;

pub var pollingError: ?Error = null;

pub fn pollEvent(lib: *Zwl, opt_window: ?*Window) Error!void {
    pollingError = null;

    var msg: W32.MSG = undefined;

    if (W32.PeekMessageW(
        &msg,
        if (opt_window) |wnd| wnd.native.handle else null,
        0,
        0,
        W32.PM_REMOVE,
    ) != 0) {
        switch (msg.message) {
            W32.WM_QUIT => try queueEvent(lib, .{ .quit = msg.wParam }),
            else => {
                _ = W32.TranslateMessage(&msg);
                _ = W32.DispatchMessageW(&msg);
            },
        }
    }

    if (pollingError) |pErr| return pErr;

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
                if (!wnd.keys[@intFromEnum(key)]) {
                    continue;
                }

                try queueEvent(lib, .{ .key = .{
                    .window = wnd,
                    .key = key,
                    .action = .release,
                    .mods = window.getKeyMods(),
                } });
            }
        }
    }
}

pub const queueEvent = event.queueEvent;
