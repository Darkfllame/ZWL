const std = @import("std");
const builtin = @import("builtin");
const ZWL = @import("zwl");
const GL = @import("zgll").GL;

const VERTEX_SHADER_SOURCE: []const u8 = @embedFile("demo.vert");
const FRAGMENT_SHADER_SOURCE: []const u8 = @embedFile("demo.frag");
const TRIANGLE_VERTICES = [_]f32{
    -0.5, -0.5, 1, 0, 0,
    0.5,  -0.5, 0, 1, 0,
    0,    0.5,  0, 0, 1,
};

pub const panic = ZWL.MBpanic;

pub fn main() !void {
    if (builtin.os.tag == .windows) {
        // manually set console output mode for windows, because zig doesn't
        _ = (opaque {
            pub extern "Kernel32" fn SetConsoleOutputCP(wCodePageID: u32) i32;
        }).SetConsoleOutputCP(65001);
    }

    const DEBUG = builtin.mode == .Debug;
    var gpa = if (DEBUG)
        std.heap.GeneralPurposeAllocator(.{}){}
    else {};
    defer _ = if (DEBUG) gpa.deinit();
    const allocator = if (DEBUG) gpa.allocator() else std.heap.page_allocator;

    const zwl = try allocator.create(ZWL.Zwl);
    defer allocator.destroy(zwl);

    errdefer |e| {
        std.debug.print("[FATAL | {s}] {s}\n", .{ @errorName(e), zwl.getError() });
    }

    try zwl.init(allocator, .{});
    defer zwl.deinit();

    const window = try zwl.createWindow(.{
        .title = "ZWL demo",
        .width = 800,
        .height = 600,
    });
    defer window.destroy();

    const ctx = try window.createGLContext(.{
        .version = .{
            .major = 3,
            .minor = 2,
        },
    });
    defer ctx.destroy();
    try zwl.makeContextCurrent(ctx);

    const gl = try allocator.create(GL);
    defer allocator.destroy(gl);
    try gl.init(null);

    std.debug.print("Using OpenGL {s}\n", .{gl.getString(GL.VERSION).?});

    var VAO: u32 = 0;
    gl.genVertexArrays(1, @ptrCast(&VAO));
    defer gl.deleteVertexArrays(1, @ptrCast(&VAO));

    var VBO: u32 = 0;
    gl.genBuffers(1, @ptrCast(&VBO));
    defer gl.deleteBuffers(1, @ptrCast(&VBO));

    gl.bindVertexArray(VAO);

    gl.bindBuffer(GL.ARRAY_BUFFER, VBO);

    gl.bufferData(GL.ARRAY_BUFFER, @sizeOf(@TypeOf(TRIANGLE_VERTICES)), &TRIANGLE_VERTICES, GL.STATIC_DRAW);

    gl.vertexAttribPointer(0, 2, GL.FLOAT, false, @sizeOf(f32) * 5, @ptrFromInt(0));
    gl.enableVertexArrayAttrib(VAO, 0);

    gl.vertexAttribPointer(1, 3, GL.FLOAT, false, @sizeOf(f32) * 5, @ptrFromInt(@sizeOf(f32) * 2));
    gl.enableVertexArrayAttrib(VAO, 1);

    gl.bindBuffer(GL.ARRAY_BUFFER, 0);

    gl.bindVertexArray(0);

    const shaderProgram = gl.createProgram();
    defer gl.deleteProgram(shaderProgram);
    {
        const vertexShader = gl.createShader(GL.VERTEX_SHADER);
        defer gl.deleteShader(vertexShader);
        gl.shaderSource(vertexShader, 1, @ptrCast(&VERTEX_SHADER_SOURCE.ptr), null);
        gl.compileShader(vertexShader);

        const fragmentShader = gl.createShader(GL.FRAGMENT_SHADER);
        defer gl.deleteShader(fragmentShader);
        gl.shaderSource(fragmentShader, 1, @ptrCast(&FRAGMENT_SHADER_SOURCE.ptr), null);
        gl.compileShader(fragmentShader);

        gl.attachShader(shaderProgram, vertexShader);
        defer gl.detachShader(shaderProgram, vertexShader);
        gl.attachShader(shaderProgram, fragmentShader);
        defer gl.detachShader(shaderProgram, fragmentShader);

        gl.linkProgram(shaderProgram);
    }

    gl.viewport(0, 0, 800, 600);
    gameloop: while (true) {
        while (try zwl.pollEvent(null)) |event| {
            switch (event) {
                .quit, .windowClosed => break :gameloop,
                else => {},
            }
        }

        gl.clearColor(0, 0, 0, 1);
        gl.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);

        gl.useProgram(shaderProgram);

        gl.bindVertexArray(VAO);
        gl.drawArrays(GL.TRIANGLES, 0, 3);
        gl.bindVertexArray(0);

        gl.useProgram(0);

        try ctx.swapBuffers();
    }
}
