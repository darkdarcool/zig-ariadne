//!
//! File cache for diagnostics, eliminating the need for multiple reads on the same file
//!

const std = @import("std");

const Allocator = std.mem.Allocator;

const Self = @This();

pub const CacheError = error{
    SourceFileNotFound,
};

alloc: Allocator,
files: std.StringHashMap([]u8),

pub fn init(alloc: Allocator) Self {
    const files = std.StringHashMap([]u8).init(alloc);
    return .{
        .alloc = alloc,
        .files = files,
    };
}

/// Add a source file to the cache
///
/// TODO: Add error handling
pub fn addSourceFile(self: *Self, file_id: []u8, file_content: []u8) void {
    _ = self.files.put(file_id, file_content) catch unreachable;
}

/// Returns a source file from the cache
///
/// Returns null if there if the `file_id` does not exist
/// in the cache
pub fn getSourceFile(self: *Self, file_id: []u8) ?[]u8 {
    return self.files.get(file_id);
}
