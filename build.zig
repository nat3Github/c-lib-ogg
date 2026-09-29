const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const libc_include = b.option(std.Build.LazyPath, "libc_include", "Build without libc against these headers; the consumer provides the symbols");

    const config_types = b.addConfigHeader(.{
        .style = .{ .autoconf_at = b.path("include/ogg/config_types.h.in") },
        .include_path = "ogg/config_types.h",
    }, .{
        .INCLUDE_INTTYPES_H = 1,
        .INCLUDE_STDINT_H = 1,
        .INCLUDE_SYS_TYPES_H = 1,
        .SIZE16 = "int16_t",
        .USIZE16 = "uint16_t",
        .SIZE32 = "int32_t",
        .USIZE32 = "uint32_t",
        .SIZE64 = "int64_t",
        .USIZE64 = "uint64_t",
    });

    const mod = b.createModule(.{ .target = target, .optimize = optimize, .link_libc = libc_include == null });
    if (libc_include) |p| mod.addIncludePath(p); // -I: must win over the macOS SDK headers zig always adds
    mod.addConfigHeader(config_types);
    mod.addIncludePath(b.path("include"));
    mod.addCSourceFiles(.{ .files = &.{ "src/bitwise.c", "src/framing.c" } });

    const lib = b.addLibrary(.{ .name = "ogg", .root_module = mod });
    lib.installConfigHeader(config_types);
    lib.installHeader(b.path("include/ogg/ogg.h"), "ogg/ogg.h");
    lib.installHeader(b.path("include/ogg/os_types.h"), "ogg/os_types.h");
    b.installArtifact(lib);
}
