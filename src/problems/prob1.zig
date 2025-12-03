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

fn rotate(dir: Direction, loc: i32, steps: i32) i32 {
    var new_loc: i32 = if (dir == .L) loc - steps else loc + steps;
    if (new_loc < 0 or new_loc >= 100) {
        new_loc = @mod(new_loc, 100);
    }
    return new_loc;
}

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !u32 {
    _ = allocator; // placeholder for future allocations
    var start_loc: i32 = 50;
    var pt_at_zero_ct: u32 = 0;

    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |raw_line| {
        const line = std.mem.trimRight(u8, raw_line, "\r");
        if (line.len == 0) continue;
        const dir: Direction = @enumFromInt(line[0]);
        const steps = try std.fmt.parseInt(i32, line[1..], 10);
        const res = rotate(dir, start_loc, steps);
        start_loc = res;
        pt_at_zero_ct += if (res == 0) 1 else 0;
    }
    return pt_at_zero_ct;
}

test "solve processes sample file" {
    const data = try readInput(std.testing.allocator, sample_path);
    defer std.testing.allocator.free(data);
    const result = try solve(std.testing.allocator, data);
    try std.testing.expectEqual(@as(i64, 3), result);
}

test "debug print sample lines" {
    const has_debug = try std.process.hasEnvVar(std.testing.allocator, "AOC_DEBUG_TESTS");
    if (!has_debug) return error.SkipZigTest;

    const data = try readInput(std.testing.allocator, sample_path);
    defer std.testing.allocator.free(data);
    try debugPrintLines(data);
}
