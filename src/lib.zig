const std = @import("std");

const Allocator = std.mem.Allocator;

const c = @cImport({
    @cInclude("ariadne_bridge.h");
});

pub fn printWithSourceAndMessage(c_file_name: [:0]u8, c_source: [:0]u8, c_message: [:0]u8) void {
    c.print_with_source_and_message(@ptrCast(c_file_name), @constCast(c_source), @constCast(c_message));
}

pub const Cache = struct {
    const Self = @This();

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
};

pub const Ariadne = struct {
    const Self = @This();

    const CacheError = error{
        SourceFileNotFound,
    };

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

    pub fn printDiagnostic(self: *Self, diagnostic: Diagnostic) CacheError!void {
        const file_content = self.cache.getSourceFile(diagnostic.file_id) orelse return CacheError.SourceFileNotFound;

        const c_file_id = self.alloc.dupeZ(u8, diagnostic.file_id) catch unreachable;
        const c_file_content = self.alloc.dupeZ(u8, file_content) catch unreachable;
        const c_message = self.alloc.dupeZ(u8, diagnostic.message) catch unreachable;

        c.print_with_source_and_message(c_file_id, c_file_content, @ptrCast(diagnostic.labels.ptr), diagnostic.labels.len, diagnostic.kind.toId(), diagnostic.error_code, c_message);
    }

    pub fn createLabel(self: *Self, file_name: []u8, span: c.Span, color: c.CColor, text: []u8) c.CLabel {
        const c_color = color;
        const c_span = span;
        const c_text = self.alloc.dupeZ(u8, text) catch unreachable;
        const c_file_name = self.alloc.dupeZ(u8, file_name) catch unreachable;

        return c.CLabel{
            .text = c_text,
            .span = c_span,
            .color = c_color,
            .file_name = c_file_name,
        };
    }

    pub fn deinit(self: *Self) void {
        self.arena.deinit();
        self.parent_alloc.destroy(self.arena);
    }
};

pub const DiagnosticKind = enum {
    Error,
    Warning,
    Advice,
    // Consider adding custom?

    pub fn toId(self: DiagnosticKind) i32 {
        return switch (self) {
            .Error => 1,
            .Warning => 2,
            .Advice => 3,
        };
    }
};

pub const Diagnostic = struct {
    kind: DiagnosticKind,
    file_id: []u8,
    labels: []Label,
    error_code: i32,
    message: []u8,
};

pub const Label = c.CLabel;
pub const Color = c.CColor;

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
