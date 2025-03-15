const std = @import("std");

const Allocator = std.mem.Allocator;

const c = @import("./interop.zig").c;

pub const Cache = @import("./Cache.zig");
pub const Label = @import("./Label.zig");
pub const Diagnostic = @import("./Diagnostic.zig");

///
/// Wrapper for the ffi bridge between Zig and Ariadne
///
pub const Ariadne = struct {
    const Self = @This();

    arena: *std.heap.ArenaAllocator,
    alloc: Allocator,
    parent_alloc: Allocator,
    cache: Cache,

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

    pub fn addSourceFile(self: *Self, file_id: []u8, file_content: []u8) void {
        self.cache.addSourceFile(file_id, file_content);
    }

    pub fn printDiagnostic(self: *Self, diagnostic: *Diagnostic) Cache.CacheError!void {
        // Create our basic diagnostic that we'll pass to c

        c.print_basic_diagnostic(try diagnostic.toC(&self.cache));
    }

    // pub fn createLabel(self: *Self, file_name: []u8, span: c.Span, color: c.Color, text: []u8) c.Label {
    //     const c_color = color;
    //     const c_span = span;
    //     const c_text = self.alloc.dupeZ(u8, text) catch unreachable;
    //     const c_file_name = self.alloc.dupeZ(u8, file_name) catch unreachable;

    //     return c.Label{
    //         .text = c_text,
    //         .span = c_span,
    //         .color = c_color,
    //         .file_name = c_file_name,
    //     };
    // }

    pub fn deinit(self: *Self) void {
        self.arena.deinit();
        self.parent_alloc.destroy(self.arena);
    }
};

pub const Color = c.Color;

pub const COLORS = enum {
    pub var RED: Color = .{
        .r = 255,
        .g = 0,
        .b = 0,
    };

    pub var BLUE: Color = .{
        .r = 0,
        .g = 0,
        .b = 255,
    };
};
