const std = @import("std");

pub const title = "Problem 0: Calibration Sum (template)";
pub const sample_path = "data/prob0_sample.txt";
pub const full_path = "data/prob0_full.txt";

const max_file_size: usize = 10 * 1024 * 1024; // 10 MiB guardrail

/// Sums signed integers separated by whitespace. Empty lines are ignored.
pub fn solvePart1(allocator: std.mem.Allocator, input: []const u8) !i64 {
    _ = allocator; // reserved for future heap usage

    var total: i64 = 0;
    var it = std.mem.tokenizeAny(u8, input, " \t\r\n");
    while (it.next()) |token| {
        total += try std.fmt.parseInt(i64, token, 10);
    }
    return total;
}

pub fn readInput(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    return try std.fs.cwd().readFileAlloc(allocator, path, max_file_size);
}

test "solve sums sample file values" {
    const data = try readInput(std.testing.allocator, sample_path);
    defer std.testing.allocator.free(data);

    const result = try solvePart1(std.testing.allocator, data);
    try std.testing.expectEqual(@as(i64, 3), result);
}

test "solve handles empty input" {
    const result = try solvePart1(std.testing.allocator, "");
    try std.testing.expectEqual(@as(i64, 0), result);
}

test "solve rejects bad tokens" {
    try std.testing.expectError(error.InvalidCharacter, solvePart1(std.testing.allocator, "12x"));
}
