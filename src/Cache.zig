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

pub fn addSourceFile(self: *Self, file_name: []u8, file_content: []u8) void {
    _ = self.files.put(file_name, file_content) catch unreachable;
}

pub fn getSourceFile(self: *Self, file_name: []u8) ?[]u8 {
    return self.files.get(file_name);
}
