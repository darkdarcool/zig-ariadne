const std = @import("std");
const c = @import("./interop.zig").c;

/// Terminal colors based on the users terminal settings
pub const TermColor = enum(c_uint) {
    primary = 0,
    //Fixed: c_int = 1,
    //Rgb: c_int = 2,
    black = c.Black,
    red = 3,
    green = 4,
    yellow = c.Yellow,
    blue = c.Blue,
    magenta = 7,
    byan = 8,
    white = 9,
    bright_black = 10,
    bright_red = 11,
    bright_green = 12,
    bright_yellow = 13,
    bright_blue = 14,
    bright_magenta = 15,
    bright_cyan = 16,
    bright_white = 17,

    pub fn toC(self: TermColor) c.Color2 {
        _ = self;
        return c.Color2{
            //.tag = @intFromEnum(self),
            .tag = c.Yellow,
        };
    }
};

const Rgb = struct {
    r: u8,
    g: u8,
    b: u8,

    pub fn toC(self: Rgb) c.Color2 {
        return c.Color2{
            .tag = c.Rgb,
            .unnamed_0 = .{
                .rgb = .{
                    ._0 = self.r,
                    ._1 = self.g,
                    ._2 = self.b,
                },
            },
        };
    }
};

pub const Color = union(enum) {
    /// Recommended coloring. Should be used whenever possible
    term_color: TermColor,
    /// Just in case you need a special color, use RGB
    custom_color: Rgb,
};

pub fn FinalizeColor(zc: Color) c.Color2 {
    return switch (zc) {
        .term_color => |izc| izc.toC(),
        .custom_color => |izc| izc.toC(),
    };
}
