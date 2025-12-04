const std = @import("std");

pub const title = "Problem 1: What's the password?";
pub const sample_path = "data/prob1_sample.txt";
pub const full_path = "data/prob1_full.txt";
const Direction = enum(u8) { L = 'L', R = 'R' };

const max_file_size: usize = 10 * 1024 * 1024; // 10 MiB guardrail

pub fn readInput(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    return try std.fs.cwd().readFileAlloc(allocator, path, max_file_size);
}

/// Prints each line from provided input for debugging.
pub fn debugPrintLines(input: []const u8) !void {
    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |raw_line| {
        const trimmed = std.mem.trimRight(u8, raw_line, "\r");
        if (trimmed.len == 0) continue;
        std.debug.print("line: {s}\n", .{trimmed});
    }
}

fn rotate(dir: Direction, loc: i32, steps: i32) struct { new_loc: i32, signed_new_loc: i32 } {
    const signed_new_loc = if (dir == .L) loc - steps else loc + steps;
    var new_loc: i32 = signed_new_loc;
    if (new_loc < 0 or new_loc >= 100) {
        new_loc = @mod(new_loc, 100);
    }
    return .{ .new_loc = new_loc, .signed_new_loc = signed_new_loc };
}

pub fn solvePart1(allocator: std.mem.Allocator, input: []const u8) !i32 {
    _ = allocator; // placeholder for future allocations
    var start_loc: i32 = 50;
    var pt_at_zero_ct: i32 = 0;

    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |raw_line| {
        const line = std.mem.trimRight(u8, raw_line, "\r");
        if (line.len == 0) continue;
        const dir: Direction = @enumFromInt(line[0]);
        const steps = try std.fmt.parseInt(i32, line[1..], 10);
        const res = rotate(dir, start_loc, steps);
        start_loc = res.new_loc;
        pt_at_zero_ct += if (res.new_loc == 0) 1 else 0;
    }
    return pt_at_zero_ct;
}

pub fn solvePart2(allocator: std.mem.Allocator, input: []const u8) !i32 {
    _ = allocator;
    var start_loc: i32 = 50;
    var pt_at_zero_ct: i32 = 0; // counting times passing or ending on zero now

    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |raw_line| {
        const line = std.mem.trimRight(u8, raw_line, "\r");
        if (line.len == 0) continue;
        const dir: Direction = @enumFromInt(line[0]);
        const steps = try std.fmt.parseInt(i32, line[1..], 10);
        const res = rotate(dir, start_loc, steps);

        const crosses = switch (dir) {
            .R => @divFloor(steps + start_loc, 100),
            .L => blk: {
                if (start_loc == 0) break :blk @divFloor(steps, 100);
                if (steps < start_loc) break :blk 0;
                break :blk 1 + @divFloor(steps - start_loc, 100);
            },
        };
        pt_at_zero_ct += crosses;
        start_loc = res.new_loc;
    }
    return pt_at_zero_ct;
}

test "solve part 1 sample file" {
    const data = try readInput(std.testing.allocator, sample_path);
    defer std.testing.allocator.free(data);
    const result = try solvePart1(std.testing.allocator, data);
    try std.testing.expectEqual(@as(i64, 3), result);
}

test "solve part 2 sample file" {
    const data = try readInput(std.testing.allocator, sample_path);
    defer std.testing.allocator.free(data);
    const result = try solvePart2(std.testing.allocator, data);
    try std.testing.expectEqual(@as(i64, 6), result);
}

test "debug print sample lines" {
    const has_debug = try std.process.hasEnvVar(std.testing.allocator, "AOC_DEBUG_TESTS");
    if (!has_debug) return error.SkipZigTest;

    const data = try readInput(std.testing.allocator, sample_path);
    defer std.testing.allocator.free(data);
    try debugPrintLines(data);
}
