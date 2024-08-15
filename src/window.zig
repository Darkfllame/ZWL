const std = @import("std");
const builtin = @import("builtin");
const config = @import("config");
const ZWL = @import("zwl.zig");

const Allocator = std.mem.Allocator;

const Error = ZWL.Error;
const GLContext = ZWL.GLContext;
const Zwl = ZWL.Zwl;

pub const Window = struct {
    owner: *Zwl,
    config: Config,
    native: ZWL.platform.Window,

    pub const Flags = packed struct {
        /// if `no_deco` is active, this field
        /// is not used.
        resizable: bool = false,
        hidden: bool = false,
        no_decoration: bool = false,
        floating: bool = false,
        hide_mouse: bool = false,
    };

    pub const Position = union(enum) {
        default,
        pos: u32,

        pub fn toNumber(self: Position, comptime default: u32) u32 {
            return switch (self) {
                .default => default,
                .pos => |pos| pos,
            };
        }
    };

    pub const SizeLimits = struct {
        wmin: ?u32 = null,
        wmax: ?u32 = null,
        hmin: ?u32 = null,
        hmax: ?u32 = null,
    };

    pub const Config = struct {
        title: []const u8,
        width: u32,
        height: u32,
        x: Position = .default,
        y: Position = .default,
        sizeLimits: SizeLimits = .{},
        flags: Flags = .{},
    };

    pub fn create(owner: *Zwl, wConfig: Config) Error!*Window {
        const self = owner.allocator.create(Window) catch |e| {
            return owner.setError("Cannot allocate window", .{}, e);
        };
        errdefer owner.allocator.destroy(self);

        std.debug.assert((wConfig.sizeLimits.wmin orelse 0) <
            (wConfig.sizeLimits.wmax orelse std.math.maxInt(u32)));
        std.debug.assert((wConfig.sizeLimits.hmin orelse 0) <
            (wConfig.sizeLimits.hmax orelse std.math.maxInt(u32)));

        self.owner = owner;
        self.config = wConfig;
        try owner.platform.window.init(&self.native, owner, wConfig);
        errdefer owner.platform.window.deinit(&self.native);

        return self;
    }

    pub fn destroy(self: *Window) void {
        self.owner.platform.window.deinit(&self.native);
        self.owner.allocator.destroy(self);
    }

    pub const createGLContext = GLContext.create;

    pub inline fn getPosition(self: *Window, x: ?*u32, y: ?*u32) void {
        return self.owner.platform.window.getPosition(self, x, y);
    }
    pub inline fn setPosition(self: *Window, x: u32, y: u32) void {
        return self.owner.platform.window.setPosition(self, x, y);
    }
    pub inline fn getSize(self: *Window, x: ?*u32, y: ?*u32) void {
        return self.owner.platform.window.getSize(self, x, y);
    }
    pub inline fn setSize(self: *Window, x: u32, y: u32) void {
        return self.owner.platform.window.setSize(self, x, y);
    }
    pub inline fn setSizeLimits(self: *Window, wmin: ?u32, wmax: ?u32, hmin: ?u32, hmax: ?u32) void {
        return self.owner.platform.window.setSizeLimits(self, wmin, wmax, hmin, hmax);
    }
    pub inline fn getFramebufferSize(self: *Window, x: ?*u32, y: ?*u32) void {
        return self.owner.platform.window.getFramebufferSize(self, x, y);
    }
    pub inline fn setVisible(self: *Window, value: bool) void {
        return self.owner.platform.window.setVisible(self, value);
    }
    pub inline fn setTitle(self: *Window, title: []const u8) Error!void {
        return self.owner.platform.window.setTitle(self, title);
    }
    /// The returned string is allocated via the allocator
    /// given to `Zwl.init()`.
    pub inline fn getTitle(self: *Window) []const u8 {
        return self.owner.platform.window.getTitle(self);
    }
    pub inline fn isFocused(self: *Window) bool {
        return self.owner.platform.window.isFocused(self);
    }
    pub inline fn setMousePos(self: *Window, x: u32, y: u32) void {
        return self.owner.platform.window.setMousePos(self, x, y);
    }
    pub inline fn getMousePos(self: *Window, x: ?*u32, y: ?*u32) void {
        return self.owner.platform.window.getMousePos(self, x, y);
    }
    pub inline fn setMouseVisible(self: *Window, value: bool) void {
        return self.owner.platform.window.setMouseVisible(self, value);
    }
};
