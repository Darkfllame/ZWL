const std = @import("std");
const builtin = @import("builtin");
const config = @import("config");
const Zwl = @import("zwl.zig");

const Allocator = std.mem.Allocator;

const Key = Zwl.Key;
const Error = Zwl.Error;
const GLContext = Zwl.GLContext;

const MAX_U32 = std.math.maxInt(u32);

pub const Window = struct {
    owner: *Zwl,
    config: Config,
    mouse: struct {
        lastY: u16 = 0,
        lastX: u16 = 0,
    } = .{},
    lastY: u16 = 0,
    lastX: u16 = 0,
    keys: [@intFromEnum(Key.last)]bool = std.mem.zeroes([@intFromEnum(Key.last)]bool),
    mouseButtons: [5]bool = [_]bool{false} ** 5,
    native: Zwl.platform.Window,

    pub const Flags = packed struct {
        /// Note:
        /// - Win32:
        ///     if `noDecoration` is active, this field
        ///     is not used.
        resizable: bool = false,
        hidden: bool = false,
        noDecoration: bool = false,
        floating: bool = false,
        hideMouse: bool = false,
        hasFocus: bool = false,
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
        aspectRatio: ?struct {
            numer: u32,
            denom: u32,
        } = null,
    };

    pub const MBMode = enum {
        ok,
        okCancel,
        abortRetryIgnore,
        yesNoCancel,
        yesNo,
        retryCancel,
        cancelTryContinue,
    };

    pub const MBButton = enum {
        ok,
        cancel,
        abort,
        retry,
        ignore,
        yes,
        no,
        tryAgain,
        @"continue",
    };

    pub const MBIcon = enum {
        none,
        @"error",
        question,
        warning,
        information,
    };

    pub const MBConfig = struct {
        title: []const u8,
        text: []const u8,
        parent: ?*Window = null,
        mode: MBMode = .ok,
        icon: MBIcon = .none,
    };

    pub fn create(owner: *Zwl, _config: Config) Error!*Window {
        const self = owner.allocator.create(Window) catch |e| {
            return owner.setError("Cannot allocate window", .{}, e);
        };
        errdefer owner.allocator.destroy(self);

        std.debug.assert((_config.sizeLimits.wmin orelse 0) <
            (_config.sizeLimits.wmax orelse MAX_U32));
        std.debug.assert((_config.sizeLimits.hmin orelse 0) <
            (_config.sizeLimits.hmax orelse MAX_U32));

        self.* = Window{
            .owner = owner,
            .config = _config,
            .native = undefined,
        };

        self.config.title = owner.allocator.dupe(u8, _config.title) catch |e| {
            return owner.setError("Cannot copy window title", .{}, e);
        };
        errdefer owner.allocator.free(self.config.title);

        try owner.platform.window.init(&self.native, owner, _config);
        errdefer owner.platform.window.deinit(&self.native);

        return self;
    }

    pub fn createMessageBox(owner: *Zwl, _config: MBConfig) Error!MBButton {
        return owner.platform.window.createMessageBox(owner, _config);
    }

    pub fn destroy(self: *Window) void {
        self.setMouseConfined(false);
        self.owner.platform.window.deinit(&self.native);
        self.owner.allocator.destroy(self);
    }

    pub const createGLContext = GLContext.create;

    pub fn getPosition(self: *Window, x: ?*u32, y: ?*u32) void {
        return self.owner.platform.window.getPosition(self, x, y);
    }
    pub fn setPosition(self: *Window, x: u32, y: u32) void {
        if (self.lastX == x and
            self.lastY == y) return;
        self.lastX = x;
        self.lastY = y;
        return self.owner.platform.window.setPosition(self, x, y);
    }
    pub fn getSize(self: *Window, w: ?*u32, h: ?*u32) void {
        if (w) |wp| wp.* = self.config.width;
        if (h) |hp| hp.* = self.config.height;
    }
    pub fn setSize(self: *Window, w: u32, h: u32) void {
        if (self.config.width == w and
            self.config.height == h) return;

        const sl = self.config.sizeLimits;
        const width = std.math.clamp(
            w,
            sl.wmin orelse 0,
            sl.wmax orelse std.math.maxInt(u32),
        );
        const height = std.math.clamp(
            h,
            sl.wmin orelse 0,
            sl.wmax orelse std.math.maxInt(u32),
        );

        self.config.width = width;
        self.config.height = height;

        if (!self.config.flags.resizable) {
            return;
        }
        return self.owner.platform.window.setSize(self, width, height);
    }
    pub fn setSizeLimits(self: *Window, wmin: ?u32, wmax: ?u32, hmin: ?u32, hmax: ?u32) void {
        std.debug.assert((wmin orelse 0) < (wmax orelse MAX_U32));
        std.debug.assert((hmin orelse 0) < (hmax orelse MAX_U32));

        self.config.sizeLimits = .{
            .wmin = wmin,
            .wmax = wmax,
            .hmin = hmin,
            .hmax = hmax,
        };

        if (!self.config.flags.resizable) {
            return;
        }

        return self.owner.platform.window.setSizeLimits(self, wmin, wmax, hmin, hmax);
    }
    pub fn getFramebufferSize(self: *Window, x: ?*u32, y: ?*u32) void {
        return self.owner.platform.window.getFramebufferSize(self, x, y);
    }
    pub fn setVisible(self: *Window, value: bool) void {
        if (self.config.flags.hidden == !value) {
            return;
        }
        self.config.flags.hidden = !value;
        return self.owner.platform.window.setVisible(self, value);
    }
    pub fn setTitle(self: *Window, title: []const u8) Error!void {
        if (std.mem.eql(u8, title, self.config.title)) {
            return;
        }
        const title_copy = self.owner.allocator.dupe(u8, title) catch |e| {
            return self.owner.setError("Cannot copy window title", .{}, e);
        };
        self.owner.allocator.free(self.config.title);
        self.config.title = title_copy;
        return self.owner.platform.window.setTitle(self, title);
    }
    /// The returned string is allocated via the allocator
    /// given to `Zwl.init()`.
    pub fn getTitle(self: *Window) []const u8 {
        return self.config.title;
    }
    pub fn isFocused(self: *Window) bool {
        return self.owner.platform.window.isFocused(self);
    }
    pub fn setMousePos(self: *Window, x: u32, y: u32) void {
        if (self.mouse.lastX == x and
            self.mouse.lastY == y) return;
        self.mouse = .{
            .lastX = @intCast(x),
            .lastY = @intCast(y),
        };
        return self.owner.platform.window.setMousePos(self, x, y);
    }
    pub fn getMousePos(self: *Window, x: ?*u32, y: ?*u32) void {
        return self.owner.platform.window.getMousePos(self, x, y);
    }
    pub fn setMouseVisible(self: *Window, value: bool) void {
        if (self.config.flags.hideMouse == !value) return;
        self.config.flags.hideMouse = !value;
        return self.owner.platform.window.setMouseVisible(self, value);
    }
    pub fn getKey(self: *Window, key: Key) bool {
        return self.keys[@intFromEnum(key)];
    }
    pub fn hasFocus(self: *Window) bool {
        return self.config.flags.hasFocus;
    }
    pub fn setFocus(self: *Window) void {
        if (self.config.flags.hasFocus) return;
        self.config.flags.hasFocus = true;
        self.owner.platform.window.setFocus(self);
    }
    pub fn setMouseConfined(self: *Window, value: bool) void {
        self.owner.platform.window.setMouseConfined(self, value);
    }
    pub fn getButton(self: *Window, button: u8) bool {
        return button < self.mouseButtons.len and self.mouseButtons[button];
    }
};
