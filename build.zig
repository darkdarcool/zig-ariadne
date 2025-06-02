const std = @import("std");
const build_crab = @import("build_crab");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const ariadne = b.addModule("ariadne", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        //.link_libcpp = true,
    });

    // Build our rust code
    const crate_artifacts = build_crab.addCargoBuild(
        b,
        .{
            //.name = "ariadne_bridge",
            .manifest_path = b.path("Cargo.toml"),
            .cargo_args = &.{
                "--release",
                "--quiet",
            },
        },
        .{
            .optimize = .ReleaseSafe,
            .target = target,
            //.optimize = optimize,
        },
    );

    // It might be better zig practice to remove this command from the "install" step and
    // have a separate step for it. This is because a package dependant on this one doesn't
    // need to generate the header file over and over again, it can be done before release
    // and commited to Git on a normal basis
    const bindings_gen = b.addSystemCommand(&.{
        "cbindgen",
        "--crate",
        "ariadne_bridge",
        "--output",
        "src/ariadne_bridge.h",
    });
    b.getInstallStep().dependOn(&bindings_gen.step);

    // Link all of the rust and ffi stuff
    ariadne.addLibraryPath(crate_artifacts);
    ariadne.linkSystemLibrary("ariadne_bridge", .{
        .needed = true,
        .preferred_link_mode = .static,
    });
    ariadne.addIncludePath(b.path("src"));

    const test_exe = b.addExecutable(.{
        .name = "ariadne-test",
        .root_source_file = b.path("src/test.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(test_exe);

    test_exe.root_module.addImport("ariadne", ariadne);

    const run_cmd = b.addRunArtifact(test_exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the tests for ariadne");
    run_step.dependOn(&run_cmd.step);
    //run_step.dependOn(&

    const check = b.step("check", "Check if zig-ariadne compiles");
    check.dependOn(&test_exe.step);
}
