const std = @import("std");
const ZWL = @import("zwl");

var zwl: ZWL.Zwl = undefined;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try zwl.init(allocator, .{});
    defer zwl.deinit();

    errdefer |e| {
        std.debug.print("[FATAL | {s}] {s}\n", .{ @errorName(e), zwl.getError() });
    }

    const window = try zwl.createWindow(.{
        .title = "ZWL demo",
        .width = 800,
        .height = 600,
    });
    defer window.destroy();

    loop: while (true) {
        while (try zwl.pollEvent()) |event| switch (event) {
            .quit, .windowClosed => break :loop,
            .key => |key| {
                std.debug.print("key {s}: {s}\n", .{ @tagName(key.action), @tagName(key.key) });
                if (key.key == .escape and key.action == .press) {
                    break :loop;
                }
            },
            else => {},
        };
    }
}
