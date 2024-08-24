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

pub const NativeFunction = struct {
    name: [:0]const u8,
    type: type,
};

pub fn FunctionLoader(comptime libName: []const u8, comptime decls: []const NativeFunction) type {
    const Type = std.builtin.Type;
    comptime var fields: [decls.len]Type.StructField = undefined;
    for (decls, 0..) |d, i| {
        fields[i] = .{
            .name = d.name,
            .type = *const GetFunctionType(d.type),
            .default_value = null,
            .is_comptime = false,
            .alignment = @alignOf(*const GetFunctionType(d.type)),
        };
    }
    const FuncList = @Type(Type{ .Struct = .{
        .layout = .auto,
        .backing_integer = null,
        .fields = &fields,
        .decls = &.{},
        .is_tuple = false,
    } });
    return struct {
        const Self = @This();
        const DynLib = std.DynLib;

        lib: DynLib,
        funcs: FuncList,

        pub fn init(self: *Self) error{ LibraryNotFound, FunctionNotFound }!void {
            var dl = DynLib.open(libName) catch return error.LibraryNotFound;
            errdefer dl.close();
            self.lib = dl;

            inline for (decls) |d| {
                @field(self.funcs, d.name) = dl.lookup(*const GetFunctionType(d.type), d.name) orelse
                    return error.FunctionNotFound;
            }
        }
        pub fn deinit(self: *Self) void {
            self.lib.close();
        }
    };
}

fn GetFunctionType(comptime T: type) type {
    const tinfo = @typeInfo(T);

    const noOptTinfo = if (tinfo == .Optional)
        @typeInfo(tinfo.Optional.child)
    else
        tinfo;

    const noPtrTinfo = if (noOptTinfo == .Pointer)
        @typeInfo(noOptTinfo.Pointer.child)
    else
        noOptTinfo;

    if (noPtrTinfo != .Fn) {
        @compileError("Expected function type, got: " ++ @typeName(T));
    }

    return @Type(noPtrTinfo);
}
