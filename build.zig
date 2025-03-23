const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const ariadne = b.addStaticLibrary(.{
        .name = "ariadne",
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    const build_rust = b.addSystemCommand(&.{ "cargo", "build", "--release" });
    const path_to_lib = b.path("./target/release/");

    // Command for generating c header file for zig bindings
    const build_c_header_file = b.addSystemCommand(&.{ "cbindgen", "--crate", "ariadne_bridge", "--output", "src/ariadne_bridge.h" });
    build_c_header_file.setCwd(b.path("./"));

    // Bunch of fun function calls for making and c and zig play nice
    ariadne.addIncludePath(b.path("src/"));
    ariadne.addLibraryPath(path_to_lib);
    ariadne.linkSystemLibrary("ariadne_bridge");
    ariadne.linkLibC();
    ariadne.addIncludePath(b.path("./"));

    ariadne.step.dependOn(&build_rust.step);
    ariadne.step.dependOn(&build_c_header_file.step);

    const test_exe = b.addExecutable(.{
        .name = "ariadne-test",
        .root_source_file = b.path("src/test.zig"),
        .target = target,
        .optimize = optimize,
    });

    test_exe.step.dependOn(&ariadne.step);

    test_exe.root_module.addImport("ariadne", ariadne.root_module);

    b.installArtifact(ariadne);

    const run_cmd = b.addRunArtifact(test_exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the tests for ariadne");
    run_step.dependOn(&run_cmd.step);

    const check = b.step("check", "Check if ariadne compiles");
    check.dependOn(&test_exe.step);
}
