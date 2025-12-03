const std = @import("std");
const prob0 = @import("problems/prob0.zig");

const Problem = struct {
    id: u8,
    title: []const u8,
};

const problems = [_]Problem{
    .{ .id = 0, .title = prob0.title },
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaks = gpa.deinit();
        if (leaks == .leak) std.log.warn("memory leak detected", .{});
    }
    const allocator = gpa.allocator();

    var args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const stdout = std.io.getStdOut().writer();

    if (args.len <= 1) {
        try showMenu(allocator, stdout);
        return;
    }

    const problem_arg = args[1];
    const remaining = args[2..];
    try dispatchProblem(allocator, stdout, problem_arg, remaining);
}

fn showMenu(allocator: std.mem.Allocator, writer: anytype) !void {
    try writer.print("zaoc25 – Advent of Code 2025\n", .{});
    try writer.print("Available problems:\n", .{});
    for (problems) |p| {
        try writer.print("  [{d}] {s}\n", .{ p.id, p.title });
    }
    try writer.print("Select a problem number (or q to quit): ", .{});

    const stdin = std.io.getStdIn().reader();
    var buffer: [64]u8 = undefined;
    const line = try stdin.readUntilDelimiterOrEof(&buffer, '\n');
    if (line == null) {
        try writer.print("\nNo input received. Exiting.\n", .{});
        return;
    }

    const trimmed = std.mem.trim(u8, line.?, " \t\r\n");
    if (trimmed.len == 0 or std.mem.eql(u8, trimmed, "q")) {
        try writer.print("Goodbye!\n", .{});
        return;
    }

    try dispatchProblem(allocator, writer, trimmed, &.{});
}

fn dispatchProblem(allocator: std.mem.Allocator, writer: anytype, problem_arg: []const u8, extra_args: []const []const u8) !void {
    if (std.mem.eql(u8, problem_arg, "0")) {
        try runProblem0(allocator, writer, extra_args);
        return;
    }

    try writer.print("Unknown problem '{s}'. Available problems: ", .{problem_arg});
    for (problems, 0..) |p, idx| {
        if (idx > 0) try writer.writeAll(", ");
        try writer.print("{d}", .{p.id});
    }
    try writer.writeByte('\n');
}

fn runProblem0(allocator: std.mem.Allocator, writer: anytype, args: []const []const u8) !void {
    // If an argument is provided, treat it as a path to input data; otherwise, use the full dataset.
    const input_path = if (args.len > 0) args[0] else prob0.full_path;
    const data = try prob0.readInput(allocator, input_path);
    defer allocator.free(data);

    const answer = try prob0.solve(allocator, data);
    try writer.print("Problem 0 answer ({s}): {d}\n", .{ input_path, answer });
}
