const std = @import("std");
const builtin = @import("builtin");
const c = @cImport({
    @cInclude("../dependencies/wayland_headers/include/wayland-client.h");
});

pub const wl_registry = opaque {};
pub const wl_surface = opaque {};
pub const wl_proxy = opaque {};
pub const wl_display = opaque {};
pub const wl_event_queue = opaque {};
pub const wl_output = opaque {};
pub const wl_compositor = opaque {};
pub const wl_subcompositor = opaque {};
pub const wl_interface = extern struct {
    name: [*:0]const u8,
    version: i32,
    method_count: i32,
    methods: [*]const wl_message,
    event_count: i32,
    events: [*]const wl_message,
};
pub const wl_message = extern struct {
    name: [*:0]const u8,
    signature: [*:0]const u8,
    types: [*:null][*]const wl_interface,
};

pub const wl_surface_listener = extern struct {
    enter: *const fn (data: ?*anyopaque, surface: *wl_surface, output: *wl_output) callconv(.C) void,
    leave: *const fn (data: ?*anyopaque, surface: *wl_surface, output: *wl_output) callconv(.C) void,
};
pub const wl_registry_listener = extern struct {
    global: *const fn (data: ?*anyopaque, registry: *wl_registry, name: u32, interface: *wl_registry, version: u32) callconv(.C) void,
    global_remove: *const fn (data: ?*anyopaque, registry: *wl_registry, name: u32) callconv(.C) void,
};

pub extern fn wl_display_connect(name: ?[*:0]const u8) ?*wl_display;
pub extern fn wl_display_disconnect(display: *wl_display) void;
pub extern fn wl_display_get_registry(display: *wl_display) *wl_registry;

pub extern fn wl_proxy_add_listener(proxy: *wl_proxy, listener: *const *const fn () void, data: ?*anyopaque) i32;
pub extern fn wl_proxy_marshal_flags(proxy: *wl_proxy, opcode: u32, interface: *const wl_interface, version: u32, flags: u32, ...) *wl_proxy;
