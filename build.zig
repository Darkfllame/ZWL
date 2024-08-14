const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const config = b.addOptions();
    addConfigOption(
        b,
        config,
        usize,
        "ERROR_BUFFER_SIZE",
        "The size (in bytes) for the error buffer",
        1024,
    );
    addConfigOption(
        b,
        config,
        []const u8,
        "DEFAULT_ERROR_MESSAGE",
        "A default error message that will be used by zwl.getError()",
        "No Error Message",
    );
    addConfigOption(
        b,
        config,
        bool,
        "USE_WAYLAND",
        "Use wayland instead of xorg for windows on linux (WIP)",
        false,
    );

    const zwl = b.addModule("zwl", .{
        .root_source_file = b.path("src/zwl.zig"),
    });
    zwl.addImport("config", config.createModule());

    const exe = b.addExecutable(.{
        .name = "zwl-demo",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("zwl", zwl);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    run_cmd.addArgs(b.args orelse &.{});

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

fn addConfigOption(
    b: *std.Build,
    config: *std.Build.Step.Options,
    comptime T: type,
    comptime name: []const u8,
    comptime description: []const u8,
    comptime default: T,
) void {
    config.addOption(T, name, b.option(T, name, std.fmt.comptimePrint(
        "{s} (default: " ++ (if (isString(T)) "\"{s}\"" else "{any}") ++ ")",
        .{ description, default },
    )) orelse default);
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