const std = @import("std");
pub const ZWL = @import("../zwl.zig");
const wayland = opaque {
    pub const init = @import("wayland/init.zig");
    pub const window = @import("wayland/window.zig");
    pub const event = @import("wayland/event.zig");
    pub const context = @import("wayland/context.zig");
};
/// Currently WIP
const x11 = opaque {
    pub const init = @import("x11/init.zig");
    pub const window = @import("x11/window.zig");
    pub const event = @import("x11/event.zig");
    pub const context = @import("x11/context.zig");
};

const Platform = ZWL.Platform;

pub const NativeData = union {
    wl: wayland.init.NativeData,
    x11: void,
};
pub const Window = union {
    // TODO: Add window
    wl: void,
    x11: void,
};
pub const GLContext = union {
    // TODO: Add window
    wl: void,
    x11: void,
};

pub fn setPlatform(lib: *Platform) ZWL.Error!void {
    lib.* = if (isWaylandSupported()) Platform{
        .init = wayland.init.init,
        .deinit = wayland.init.deinit,
        // TODO: Add implementation:
        .window = undefined,
        .event = undefined,
        .glContext = undefined,
    } else @panic("X11 fallback is currently WIP");
}

fn isWaylandSupported() bool {
    var e_dl = std.DynLib.open("libwayland-client.so.0");
    return if (e_dl) |*dl| {
        dl.close();
        return true;
    } else |_| return false;
}
