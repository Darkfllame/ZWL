const std = @import("std");
const builtin = @import("builtin");
const config = @import("config");
const Zwl = @import("Zwl.zig");
pub const Key = @import("key.zig").Key;

const Error = Zwl.Error;
const Window = Zwl.Window;

pub const Event = union(enum) {
    quit: u64,
    windowClosed: *Window,
    windowFocused: struct {
        window: *Window,
        gained: bool,
    },
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
    mouseButton: struct {
        window: *Window,
        clicked: bool,
        /// | value | button |
        /// |-|-|
        /// |1|left|
        /// |2|middle|
        /// |3|right|
        /// |4|4th button|
        /// |5|5th button|
        /// and so on...
        button: u8,
        mods: EventMods,
    },
    mouseWheel: struct {
        window: *Window,
        x: f32,
        y: f32,
        mods: EventMods,
    },
    key: struct {
        window: *Window,
        key: Key,
        action: Key.Action,
        mods: Key.Mods,
    },

    pub const EventMods = packed struct {
        control: bool,
        shift: bool,
    };
};

pub fn pollEvent(lib: *Zwl, opt_window: ?*Window) Error!?Event {
    return popQueue(lib) orelse {
        try lib.platform.event.pollEvent(lib, opt_window);
        return popQueue(lib);
    };
}

fn popQueue(lib: *Zwl) ?Event {
    if (lib.eventQueueSize > 0) {
        const retItem = lib.eventQueue[0];
        lib.eventQueueSize -= 1;
        if (lib.eventQueueSize > 1) {
            for (lib.eventQueue[1..lib.eventQueueSize], 0..) |item, i| {
                lib.eventQueue[i] = item;
            }
        }
        return retItem;
    }
    return null;
}

pub fn queueEvent(lib: *Zwl, event: Event) Error!void {
    const newSize = lib.eventQueueSize + 1;
    if (newSize > lib.eventQueue.len) {
        return Error.QueueFull;
    }
    lib.eventQueue[newSize - 1] = event;
    lib.eventQueueSize = newSize;
}
