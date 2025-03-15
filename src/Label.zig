const std = @import("std");
const c = @import("./interop.zig").c;

const Allocator = std.mem.Allocator;

const Self = @This();

file_name: []u8,
span: c.Span,
color: c.Color,
text: []u8,

pub fn create(file_name: []u8, span: c.Span, color: c.Color, text: []u8) Self {
    return Self{
        .file_name = file_name,
        .span = span,
        .color = color,
        .text = text,
    };
}

pub fn toC(self: *Self, alloc: Allocator) c.Label {
    const c_text = alloc.dupeZ(u8, self.text) catch unreachable;
    const c_file_name = alloc.dupeZ(u8, self.file_name) catch unreachable;

    return c.Label{
        .text = c_text,
        .span = self.span,
        .color = self.color,
        .file_name = c_file_name,
    };
}
