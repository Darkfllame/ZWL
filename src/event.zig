const std = @import("std");
const builtin = @import("builtin");
const config = @import("config");
const ZWL = @import("zwl.zig");
pub const Key = @import("key.zig").Key;

const Error = ZWL.Error;
const Window = ZWL.Window;
const Zwl = ZWL.Zwl;

const Native = switch (builtin.os.tag) {
    .windows => @import("windows/event.zig"),
    .linux => @import("linux/event.zig"),
    .macos => @import("macos/event.zig"),
    else => @compileError("Unsupported target"),
};

comptime {
    ZWL.checkNativeDecls(Native, &.{
        .{ .name = "pollEvent", .type = fn (*Zwl, ?*Window) Error!?Event },
    });
}

pub const Event = union(enum) {
    quit: u64,
    windowClosed: *Window,
    windowResized: struct {
        window: *Window,
        width: u16,
        height: u16,
    },
    windowMoved: struct {
        window: *Window,
        x: u16,
        y: u16,
    },
    mouseMoved: struct {
        window: *Window,
        x: u16,
        y: u16,
        dx: i16,
        dy: i16,
    },
    key: struct {
        window: *Window,
        key: Key,
        action: Key.Action,
        mods: Key.Mods,
    },
};

pub inline fn pollEvent(lib: *Zwl, opt_window: ?*Window) Error!?Event {
    return Native.pollEvent(lib, opt_window);
}
