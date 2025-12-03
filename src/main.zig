const std = @import("std");
const prob0 = @import("problems/prob0.zig");
const prob1 = @import("problems/prob1.zig");

const Problem = struct {
    id: u8,
    title: []const u8,
    label: []const u8,
    default_path: []const u8,
    run: *const fn (std.mem.Allocator, std.io.AnyWriter, []const []const u8) anyerror!void,
};

fn mkProblem(comptime ResultType: type, comptime id: u8, title: []const u8, default_path: []const u8, label: []const u8, readInputFn: fn (std.mem.Allocator, []const u8) anyerror![]u8, solveFn: fn (std.mem.Allocator, []const u8) anyerror!ResultType) Problem {
    return .{
        .id = id,
        .title = title,
        .label = label,
        .default_path = default_path,
        .run = struct {
            fn go(allocator: std.mem.Allocator, writer: std.io.AnyWriter, args: []const []const u8) anyerror!void {
                const input_path = if (args.len > 0) args[0] else default_path;
                const data = try readInputFn(allocator, input_path);
                defer allocator.free(data);

                const answer = try solveFn(allocator, data);
                try writer.print("{s} ({s}): {any}\n", .{ label, input_path, answer });
            }
        }.go,
    };
}

const problems = [_]Problem{
    mkProblem(i64, 0, prob0.title, prob0.full_path, "Problem 0 answer", prob0.readInput, prob0.solve),
    mkProblem(u32, 1, prob1.title, prob1.full_path, "Problem 1 answer", prob1.readInput, prob1.solve),
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
    const id = std.fmt.parseInt(u8, problem_arg, 10) catch {
        try writer.print("Unknown problem '{s}'. Enter a numeric id.\n", .{problem_arg});
        return;
    };
    const any_writer = writer.any();
    inline for (problems) |p| {
        if (p.id == id) {
            try p.run(allocator, any_writer, extra_args);
            return;
        }
    }

    try writer.print("Unknown problem '{s}'. Available problems: ", .{problem_arg});
    for (problems, 0..) |p, idx| {
        if (idx > 0) try writer.writeAll(", ");
        try writer.print("{d}", .{p.id});
    }
    try writer.writeByte('\n');
}
