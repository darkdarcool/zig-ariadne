const std = @import("std");

const Allocator = std.mem.Allocator;

pub const c = @import("./interop.zig").c;

pub const Cache = @import("./Cache.zig");
pub const Label = @import("./Label.zig");
pub const Diagnostic = @import("./Diagnostic.zig");
pub const color = @import("./color.zig");

///
/// Wrapper for the ffi bridge between Zig and Ariadne
///
pub const Ariadne = struct {
    const Self = @This();

    arena: *std.heap.ArenaAllocator,
    alloc: Allocator,
    parent_alloc: Allocator,
    cache: Cache,

    /// Create a new wrapper
    pub fn init(_alloc: Allocator) Self {
        var arena_allocator = _alloc.create(std.heap.ArenaAllocator) catch unreachable;

        arena_allocator.* = std.heap.ArenaAllocator.init(_alloc);

        const _a = arena_allocator.allocator();

        return .{
            .arena = arena_allocator,
            .alloc = _a,
            .parent_alloc = _alloc,
            .cache = Cache.init(_a),
        };
    }

    /// Helper function to add a file to the cache
    pub fn addSourceFile(self: *Self, file_id: []u8, file_content: []u8) void {
        self.cache.addSourceFile(file_id, file_content);
    }

    /// Print a basic diagnostic to stderr
    pub fn printDiagnostic(self: *Self, diagnostic: *Diagnostic) Cache.CacheError!void {
        const c_diagnostic = try diagnostic.toC(&self.cache);
        defer self.deinitDiagnostic(c_diagnostic);

        c.print_basic_diagnostic(c_diagnostic);
    }

    fn deinitDiagnostic(self: *Self, c_diagnostic: c.BasicDiagnostic) void {
        const file_content = std.mem.sliceTo(c_diagnostic.c_file_content, 0);
        self.alloc.free(file_content);
        const file_name = std.mem.sliceTo(c_diagnostic.c_file_name, 0);
        self.alloc.free(file_name);
        const message = std.mem.sliceTo(c_diagnostic.c_message, 0);
        self.alloc.free(message);
    }

    pub fn deinit(self: *Self) void {
        self.cache.deinit();
        self.arena.deinit();
        self.parent_alloc.destroy(self.arena);
    }
};
