const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zgll = b.dependency("zgll", .{}).module("zgll");
    b.modules.put(b.dupe("zgll"), zgll) catch @panic("OOM");

    const config = b.addOptions();
    _ = addConfigOption(
        b,
        config,
        usize,
        "ERROR_BUFFER_SIZE",
        "The size (in bytes) for the error buffer",
        1024,
    );
    _ = addConfigOption(
        b,
        config,
        []const u8,
        "DEFAULT_ERROR_MESSAGE",
        "A default error message that will be used by zwl.getError()",
        "No Error Message",
    );
    _ = addConfigOption(
        b,
        config,
        usize,
        "EVENT_QUEUE_SIZE",
        "The internal event queue size",
        16,
    );

    const zwl = b.addModule("zwl", .{
        .root_source_file = b.path("src/zwl.zig"),
        .target = target,
        .optimize = optimize,
    });
    zwl.addImport("config", config.createModule());

    const exe = b.addExecutable(.{
        .name = "zwl-demo",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("zwl", zwl);
    exe.root_module.addImport("zgll", zgll);
    if (optimize != .Debug) {
        exe.subsystem = .Windows;
    }

    const bootstrap_shared_dir = b.fmt("{s}/bootstrap_so", .{b.install_prefix});
    if (builtin.os.tag != target.result.os.tag) {
        zwl.addLibraryPath(.{ .cwd_relative = bootstrap_shared_dir });
    }

    // Bootstrap shared libraries for
    // forein compilation
    switch (target.result.os.tag) {
        .windows => if (builtin.os.tag != .windows) {
            addBootstrapSharedLib(b, target, optimize, "Kernel32", "src/windows/kernel32_bs.zig");
            addBootstrapSharedLib(b, target, optimize, "User32", "src/windows/user32_bs.zig");
            addBootstrapSharedLib(b, target, optimize, "Gdi32", "src/windows/gdi32_bs.zig");
            addBootstrapSharedLib(b, target, optimize, "Opengl32", "src/windows/opengl32_bs.zig");
        },
        else => {},
    }

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    run_cmd.addArgs(b.args orelse &.{});

    const run_step = b.step("run", "Run a simple demo, showing a colored triangle " ++
        "to a window with OpenGL");
    run_step.dependOn(&run_cmd.step);
}

fn addConfigOption(
    b: *std.Build,
    config: *std.Build.Step.Options,
    comptime T: type,
    comptime name: []const u8,
    comptime description: []const u8,
    comptime default: T,
) T {
    const v = b.option(T, name, std.fmt.comptimePrint(
        "{s} (default: " ++ (if (isString(T)) "\"{s}\"" else "{any}") ++ ")",
        .{ description, default },
    )) orelse default;
    config.addOption(T, name, v);
    return v;
}

fn isString(comptime T: type) bool {
    const tinfo = @typeInfo(T);
    if (tinfo != .Pointer) {
        if (tinfo == .Array and tinfo.Array.child == u8) {
            return true;
        }
        return false;
    }
    if (tinfo.Pointer.size == .Many and tinfo.Pointer.sentinel == null) return false;
    return (tinfo.Pointer.size != .One) and tinfo.Pointer.child == u8;
}

fn addBootstrapSharedLib(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    name: []const u8,
    sub_path: []const u8,
) void {
    const lib = b.addSharedLibrary(.{
        .name = name,
        .root_source_file = b.path(sub_path),
        .target = target,
        .optimize = optimize,
    });
    b.getInstallStep().dependOn(&b.addInstallArtifact(lib, .{
        .dest_dir = .{ .override = .{ .custom = "bootstrap_so" } },
        .implib_dir = .{ .override = .{ .custom = "bootstrap_so" } },
        .pdb_dir = .disabled,
    }).step);
}
