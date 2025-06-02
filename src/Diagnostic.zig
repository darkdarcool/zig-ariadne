const std = @import("std");
const c = @import("interop.zig").c;
const Label = @import("./Label.zig");
const Cache = @import("./Cache.zig");

const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const Self = @This();

const Labels = std.ArrayList(c.Label);

/// The kind of diagnostic being emitted
///
/// ```
/// [05] Error: There was an error
///      ^^^^^
/// ```
///
/// The kind of diagnostic also changes its color:
/// * `Error` is red
/// * `Warning` is yellow
/// * `Advice` is blue (Fixed 147)
///
/// See https://github.com/zesterer/ariadne/blob/3c723bf56468f0b30eab8335cd437597ae0648ad/src/lib.rs#L527-L535
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

arena: *std.heap.ArenaAllocator,
alloc: Allocator,
parent_alloc: Allocator,

kind: DiagnosticKind,
file_id: []u8,
labels: Labels,
error_code: i32,
message: []u8,

// zig fmt: off

/// Initialize a new diagnostic message
///
/// `file_id` is the EXACT identifier used in the cache 
/// for the file being referenced
///
/// ```
///      kind
///       v
/// [05] Error: There was an error
///  ^            ^ 
/// error_code  message
/// ```
pub fn init(
    _alloc: Allocator, 
    file_id: []u8,
    kind: DiagnosticKind, 
    error_code: i32, 
    message: []u8
) Self {
    var arena_allocator = _alloc.create(std.heap.ArenaAllocator) catch unreachable;

    arena_allocator.* = std.heap.ArenaAllocator.init(_alloc);

    const _a = arena_allocator.allocator();

    return Self{
        .arena = arena_allocator,
        .alloc = _a,
        .parent_alloc = _alloc,

        .labels = Labels.init(_a),
        .kind = kind,
        .file_id = file_id,
        .error_code = error_code,
        .message = message,
    };
}

/// Adds a label to the diagnostic
pub fn addLabel(self: *Self, label: *Label) !void {
    try self.labels.append(label.toC(self.alloc));
}

/// Do not call. Internal use only
/// 
/// Converts the diagnostic to FFI usable data structure
pub fn toC(self: *Self, cache: *Cache) Cache.CacheError!c.BasicDiagnostic {
    const file_content = cache.getSourceFile(self.file_id) orelse return Cache.CacheError.SourceFileNotFound;

    // Null terminate all of our strings for c interop
    const c_file_id = self.alloc.dupeZ(u8, self.file_id) catch unreachable;
    const c_file_content = self.alloc.dupeZ(u8, file_content) catch unreachable;
    const c_message = self.alloc.dupeZ(u8, self.message) catch unreachable;

    const labels_slice = self.labels.items;

    // Create our basic diagnostic that we'll pass to c
    return c.BasicDiagnostic{
        .c_file_name = c_file_id,
        .c_file_content = c_file_content,
        .c_labels = @ptrCast(labels_slice.ptr),
        .c_labels_len = labels_slice.len,
        .c_kind = self.kind.toId(),
        .c_error_code = self.error_code,
        .c_message = c_message,
    };
}

pub fn deinit(self: *Self) void {
    self.labels.deinit();
    self.arena.deinit();
    self.parent_alloc.destroy(self.arena);
}
