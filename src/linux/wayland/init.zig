const std = @import("std");
const WL = @import("wl.zig");
const ZWL = @import("../platform.zig").ZWL;

const Error = ZWL.Error;
const Zwl = ZWL.Zwl;

const registryListener = WL.wl_registry_listener{
    .global = registryHandleGlobal,
    .global_remove = registryHandleGlobalRemove,
};

fn registryHandleGlobal(
    ud: ?*anyopaque,
    registry: *WL.wl_registry,
    name: u32,
    interface: *WL.wl_interface,
    version: u32,
) callconv(.C) void {
    const eql = struct {
        inline fn inner(a: []const u8, b: []const u8) bool {
            return std.mem.eql(u8, a, b);
        }
    }.inner;
    const lib: *NativeData = @as(*Zwl, @ptrCast(ud)).native.wl;
    const spanName = std.mem.span(interface.name);
    if (eql(spanName, "wl_compositor")) {
        lib.compositor = lib.client.funcs.wl_proxy_marshal_flags(
            @ptrCast(registry),
            0,
            name,
            &interface,
            @min(3, version),
            0,
            interface.name,
        );
    }
}

fn registryHandleGlobalRemove(ud: ?*anyopaque, registry: *WL.wl_registry, name: u32) callconv(.C) void {
    _ = ud; // autofix
    _ = registry; // autofix
    _ = name; // autofix

}

pub const NativeData = struct {
    /// libwayland-client.so.0
    client: ZWL.FunctionLoader("libwayland-client.so.0", &.{
        .{ .name = "wl_display_connect", .type = @TypeOf(WL.wl_display_connect) },
        .{ .name = "wl_display_disconnect", .type = @TypeOf(WL.wl_display_disconnect) },
        .{ .name = "wl_display_get_registry", .type = @TypeOf(WL.wl_display_get_registry) },
        .{ .name = "wl_proxy_add_listener", .type = @TypeOf(WL.wl_proxy_add_listener) },
        .{ .name = "wl_proxy_marshal_flags", .type = @TypeOf(WL.wl_proxy_marshal_flags) },
    }),
    display: *WL.wl_display,
    registry: *WL.wl_registry,
    compositor: *WL.wl_compositor,
};

pub fn init(lib: *Zwl) Error!void {
    lib.native = .{ .wl = undefined };
    const wl: *NativeData = &lib.native.wl;
    wl.client.init() catch |e| {
        switch (e) {
            error.LibraryNotFound => unreachable,
            error.FunctionNotFound => return lib.setError(
                "Cannot load library \"libwayland-client\": {s}",
                .{@errorName(e)},
                Error.Wayland,
            ),
        }
    };
    errdefer wl.client.deinit();
    const wlcl = &wl.client.funcs;

    const display = wlcl.wl_display_connect(null) orelse {
        return lib.setError("Cannot connect to diplay", .{}, Error.Wayland);
    };
    errdefer wlcl.wl_display_disconnect(display);

    wl.registry = wlcl.wl_display_get_registry(display);
    wl.display = display;

    wlcl.wl_proxy_add_listener(wl.registry, &registryListener, @ptrCast(lib));
}

pub fn deinit(lib: *Zwl) void {
    lib.native.wl.client.deinit();
}
