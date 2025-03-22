const std = @import("std");
const c = @import("./interop.zig").c;
const Color = @import("./color.zig").Color;
const FinalizeColor = @import("./color.zig").FinalizeColor;

const Allocator = std.mem.Allocator;

const Self = @This();

file_id: []u8,
span: c.Span,
color: c.Color2,
text: []u8,

// zig fmt: off

/// Create a new Label for a diagnostic
///
/// With regards with line and column number of a an error,
/// it's calculated with `span` by ariadne
pub fn init(
    file_id: []u8, 
    span: c.Span, 
    color: Color, 
    text: []u8
) Self {
    return Self{
        .file_id = file_id,
        .span = span,
        .color = FinalizeColor(color),
        .text = text,
    };
}

/// Internal use only. Do not use
pub fn toC(self: *Self, alloc: Allocator) c.Label {
    const c_text = alloc.dupeZ(u8, self.text) catch unreachable;
    const c_file_id = alloc.dupeZ(u8, self.file_id) catch unreachable;

    return c.Label{
        .text = c_text,
        .span = self.span,
        .color = self.color,
        .file_name = c_file_id,
    };
}
