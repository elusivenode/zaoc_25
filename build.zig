const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zaoc25",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| run_cmd.addArgs(args);
    const run_step = b.step("run", "Run the Advent of Code CLI");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run problem libraries tests");
    const test_prob0 = b.addSystemCommand(&[_][]const u8{
        b.graph.zig_exe,
        "test",
        b.pathJoin(&.{ "src", "problems", "prob0.zig" }),
    });
    test_prob0.setEnvironmentVariable("ZIG_GLOBAL_CACHE_DIR", "zig-cache");
    test_prob0.setEnvironmentVariable("ZIG_LOCAL_CACHE_DIR", "zig-cache");
    test_step.dependOn(&test_prob0.step);

    const test_prob1 = b.addSystemCommand(&[_][]const u8{
        b.graph.zig_exe,
        "test",
        b.pathJoin(&.{ "src", "problems", "prob1.zig" }),
    });
    test_prob1.setEnvironmentVariable("ZIG_GLOBAL_CACHE_DIR", "zig-cache");
    test_prob1.setEnvironmentVariable("ZIG_LOCAL_CACHE_DIR", "zig-cache");
    test_step.dependOn(&test_prob1.step);
}
