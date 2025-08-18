const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const examples = [_]struct {
        file: []const u8,
        name: []const u8,
        libc: bool = false,
    }{
        .{ .file = "examples/01_piano/App.zig", .name = "example_1" },
        .{ .file = "examples/02_core-triangle/App.zig", .name = "example_2" },
        .{ .file = "examples/03_core-custom-entrypoint/App.zig", .name = "example_3" },
    };

    {
        for (examples) |ex| {
            // Create our Mach app module, where all our code lives.
            const app_mod = b.createModule(.{
                .root_source_file = b.path(ex.file),
                .optimize = optimize,
                .target = target,
            });

            // Add Mach import to our app.
            const mach_dep = b.dependency("mach", .{
                .target = target,
                .optimize = optimize,
            });
            app_mod.addImport("mach", mach_dep.module("mach"));

            // Have Mach create the executable for us
            const exe = @import("mach").addExecutable(mach_dep.builder, .{
                .name = ex.name,
                .app = app_mod,
                .target = target,
                .optimize = optimize,
            });
            b.installArtifact(exe);

            // Run the app when `zig build run` is invoked
            const run_cmd = b.addRunArtifact(exe);
            run_cmd.step.dependOn(b.getInstallStep());
            if (b.args) |args| {
                run_cmd.addArgs(args);
            }
            const run_step = b.step(ex.name, "Run the app");
            run_step.dependOn(&run_cmd.step);

            // // Run tests when `zig build test` is run
            // const app_unit_tests = b.addTest(.{
            //     .root_module = app_mod,
            // });
            // const run_app_unit_tests = b.addRunArtifact(app_unit_tests);
            // const test_step = b.step("test", "Run unit tests");
            // test_step.dependOn(&run_app_unit_tests.step);
        }
    }
}
