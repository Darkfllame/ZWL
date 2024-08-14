const std = @import("std");
const builtin = @import("builtin");
const mconfig = @import("config");
const ZWL = @import("zwl.zig");

const Allocator = std.mem.Allocator;

const Error = ZWL.Error;
const Zwl = ZWL.Zwl;

const Native = switch (builtin.os.tag) {
    .windows => @import("windows/window.zig"),
    .linux => if (mconfig.USE_WAYLAND)
        @import("linux/wayland/window.zig")
    else
        @import("linux/xorg/window.zig"),
    .macos => @import("macos/window.zig"),
    .ios => @import("ios/window.zig"),
    else => @compileError("Unsupported target"),
};

comptime {
    if (!@hasDecl(Native, "NativeWindow")) {
        @compileError("Native API doesn't have NativeWindow");
    }
    if (@TypeOf(Native.NativeWindow) != type) {
        @compileError("Native.NativeWindow expected to be a type");
    }
    const nwInfo = @typeInfo(Native.NativeWindow);
    switch (nwInfo) {
        .Struct, .Opaque, .Enum, .Union => {},
        else => @compileError("Native.NativeWindow expected to be a struct, opaque, enum or union, got: " ++ @tagName(nwInfo)),
    }

    ZWL.checkNativeDecls(Native.NativeWindow, &.{
        .{ .name = "init", .type = fn (*Native.NativeWindow, *Zwl, Window.Config) Error!void },
        .{ .name = "deinit", .type = fn (*Native.NativeWindow) void },
        .{ .name = "getPosition", .type = fn (*Window, ?*u32, ?*u32) void },
        .{ .name = "setPosition", .type = fn (*Window, u32, u32) void },
        .{ .name = "getSize", .type = fn (*Window, ?*u32, ?*u32) void },
        .{ .name = "setSize", .type = fn (*Window, u32, u32) void },
        .{ .name = "setSizeLimits", .type = fn (*Window, ?u32, ?u32, ?u32, ?u32) void },
        .{ .name = "getFramebufferSize", .type = fn (*Window, ?*u32, ?*u32) void },
        .{ .name = "setVisible", .type = fn (*Window, bool) void },
        .{ .name = "setTitle", .type = fn (*Window, []const u8) Error!void },
        .{ .name = "getTitle", .type = fn (*Window) []const u8 },
        .{ .name = "isFocused", .type = fn (*Window) bool },
        .{ .name = "getMousePos", .type = fn (*Window, ?*u32, ?*u32) void },
        .{ .name = "setMousePos", .type = fn (*Window, u32, u32) void },
    });
}

pub const Window = struct {
    owner: *Zwl,
    config: Config,
    native: Native.NativeWindow,

    pub const Flags = packed struct {
        /// if `no_deco` is active, this field
        /// is not used.
        resizable: bool = false,
        hidden: bool = false,
        no_decoration: bool = false,
        floating: bool = false,
        hideCursor: bool = false,
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

    pub fn create(owner: *Zwl, config: Config) Error!*Window {
        const self = owner.allocator.create(Window) catch |e| {
            return owner.setError("Cannot allocate window", .{}, e);
        };
        errdefer owner.allocator.destroy(self);

        std.debug.assert((config.sizeLimits.wmin orelse 0) <
            (config.sizeLimits.wmax orelse std.math.maxInt(u32)));
        std.debug.assert((config.sizeLimits.hmin orelse 0) <
            (config.sizeLimits.hmax orelse std.math.maxInt(u32)));

        self.owner = owner;
        self.config = config;
        try self.native.init(owner, config);
        errdefer self.native.deinit();

        return self;
    }

    pub fn destroy(self: *Window) void {
        self.native.deinit();
        self.owner.allocator.destroy(self);
    }

    pub const getPosition = Native.NativeWindow.getPosition;
    pub const setPosition = Native.NativeWindow.setPosition;
    pub const getSize = Native.NativeWindow.getSize;
    pub const setSize = Native.NativeWindow.setSize;
    pub const setSizeLimits = Native.NativeWindow.setSizeLimits;
    pub const getFramebufferSize = Native.NativeWindow.getFramebufferSize;
    pub const setVisible = Native.NativeWindow.setVisible;
    pub const setTitle = Native.NativeWindow.setTitle;
    pub const getTitle = Native.NativeWindow.getTitle;
    pub const isFocused = Native.NativeWindow.isFocused;
    pub const setMousePos = Native.NativeWindow.setMousePos;
    pub const getMousePos = Native.NativeWindow.getMousePos;
    pub const setMouseVisible = Native.NativeWindow.setMouseVisible;
};
