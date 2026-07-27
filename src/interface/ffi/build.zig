// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// knot-rider FFI build (Zig 0.16.0+)
//
// Builds src/main.zig as a C-ABI static library (the FFI seam consumed by
// the Idris2 ABI side) and wires `zig build test` to the real test suites
// in src/main.zig and test/integration_test.zig.

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const lib = b.addLibrary(.{
        .name = "knot_rider",
        .root_module = mod,
        .linkage = .static,
    });
    b.installArtifact(lib);

    const test_step = b.step("test", "Run the FFI unit + integration tests");

    const main_tests = b.addTest(.{ .root_module = mod });
    test_step.dependOn(&b.addRunArtifact(main_tests).step);

    const integration_mod = b.createModule(.{
        .root_source_file = b.path("test/integration_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const integration_tests = b.addTest(.{ .root_module = integration_mod });
    test_step.dependOn(&b.addRunArtifact(integration_tests).step);
}
