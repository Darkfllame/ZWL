const std = @import("std");
const ZWL = @import("../zwl.zig");
const W32 = @import("w32.zig");

const Window = ZWL.Window;
const Error = ZWL.Error;
const Event = ZWL.Event;
const Zwl = ZWL.Zwl;

pub var polledEvent: ?Event = null;
pub var polledEvent2: ?Event = null;

pub fn pollEvent(lib: *Zwl, opt_window: ?*Window) Error!?Event {
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

    if (lib.native.disabledMouseWindow) |window| {
        var width: u32 = undefined;
        var height: u32 = undefined;
        window.getSize(&width, &height);

        if (window.native.lastMouseX != width / 2 or
            window.native.lastMouseY != height / 2)
        {
            window.setMousePos(width / 2, height / 2);
        }
    }

    return null;
}
