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
    const ctx = try window.createGLContext(.{});
    defer ctx.destroy();
    try zwl.makeContextCurrent(ctx);

    gameloop: while (true) {
        while (try zwl.pollEvent(null)) |event| {
            switch (event) {
                .quit, .windowClosed => break :gameloop,
                else => {},
            }
        }
    }
}
