use ariadne::{Color as AColor, ReportKind};
use std::ffi::{CStr, CString};

extern crate libc;

macro_rules! cstr_to_str {
    ($cstr:expr) => {
        unsafe { CStr::from_ptr($cstr) }.to_str().unwrap()
    };
}

pub(crate) use cstr_to_str;

/// Holy sigma
#[derive(Clone, Debug)]
#[repr(C)]
pub struct Span {
    pub(crate) start: usize,
    pub(crate) end: usize,
}

#[derive(Clone, Debug, Copy)]
#[repr(C)]
pub struct Color {
    pub(crate) r: u8,
    pub(crate) g: u8,
    pub(crate) b: u8,
}

#[derive(Clone, Debug, Copy)]
#[repr(C)]
pub enum Color2 {
    /// Terminal primary color #9. (foreground code `39`, background code `49`).
    ///
    /// This is the terminal's defined "primary" color, that is, the configured
    /// default foreground and background colors. As such, this color as a
    /// foreground looks "good" against the terminal's default background color,
    /// and this color is a "good" background color for the terminal's default
    /// foreground color.
    Primary,

    /// A color from 0 to 255, for use in 256-color terminals.
    Fixed(u8),

    /// A 24-bit
    /// <span style="background: red; color: white;">R</span>
    /// <span style="background: green; color: white;">G</span>
    /// <span style="background: blue; color: white;">B</span>
    /// "true color", as specified by ISO-8613-3.
    Rgb(u8, u8, u8),

    /// <span style="background: black; color: white;">Black #0</span>
    /// (foreground code `30`, background code `40`).
    Black,

    /// <span style="background: red; color: white;">Red #1</span>
    /// (foreground code `31`, background code `41`).
    Red,

    /// <span style="background: green; color: white;">Green: #2</span>
    /// (foreground code `32`, background code `42`).
    Green,

    /// <span style="background: gold; color: black;">Yellow: #3</span>
    /// (foreground code `33`, background code `43`).
    Yellow,

    /// <span style="background: blue; color: white;">Blue: #4</span>
    /// (foreground code `34`, background code `44`).
    Blue,

    /// <span style="background: darkmagenta; color: white;">Magenta: #5</span>
    /// (foreground code `35`, background code `45`).
    Magenta,

    /// <span style="background: deepskyblue; color: black;">Cyan: #6</span>
    /// (foreground code `36`, background code `46`).
    Cyan,

    /// <span style="background: #eeeeee; color: black;">White: #7</span>
    /// (foreground code `37`, background code `47`).
    White,

    /// <span style="background: gray; color: white;">Bright Black #0</span>
    /// (foreground code `90`, background code `100`).
    BrightBlack,

    /// <span style="background: hotpink; color: white;">Bright Red #1</span>
    /// (foreground code `91`, background code `101`).
    BrightRed,

    /// <span style="background: greenyellow; color: black;">Bright Green: #2</span>
    /// (foreground code `92`, background code `102`).
    BrightGreen,

    /// <span style="background: yellow; color: black;">Bright Yellow: #3</span>
    /// (foreground code `93`, background code `103`).
    BrightYellow,

    /// <span style="background: dodgerblue; color: white;">Bright Blue: #4</span>
    /// (foreground code `94`, background code `104`).
    BrightBlue,

    /// <span style="background: magenta; color: white;">Bright Magenta: #5</span>
    /// (foreground code `95`, background code `105`).
    BrightMagenta,

    /// <span style='background: cyan; color: black;'>Bright Cyan: #6</span>
    /// (foreground code `96`, background code `106`).
    BrightCyan,

    /// <span style="background: white; color: black;">Bright White: #7</span>
    /// (foreground code `97`, background code `107`).
    BrightWhite,
}

impl Into<ariadne::Color> for Color2 {
    fn into(self) -> ariadne::Color {
        return match self {
            Self::Primary => ariadne::Color::Primary,
            Self::Fixed(c) => ariadne::Color::Fixed(c),
            Self::Rgb(r, g, b) => ariadne::Color::Rgb(r, g, b),
            Self::Black => ariadne::Color::Black,
            Self::Red => ariadne::Color::Red,
            Self::Green => ariadne::Color::Green,
            Self::Yellow => ariadne::Color::Yellow,
            Self::Blue => ariadne::Color::Blue,
            Self::Magenta => ariadne::Color::Magenta,
            Self::Cyan => ariadne::Color::Cyan,
            Self::White => ariadne::Color::White,
            Self::BrightBlack => ariadne::Color::BrightBlack,
            Self::BrightRed => ariadne::Color::BrightRed,
            Self::BrightGreen => ariadne::Color::BrightGreen,
            Self::BrightYellow => ariadne::Color::BrightYellow,
            Self::BrightBlue => ariadne::Color::BrightBlue,
            Self::BrightMagenta => ariadne::Color::BrightMagenta,
            Self::BrightCyan => ariadne::Color::BrightCyan,
            Self::BrightWhite => ariadne::Color::BrightWhite,
        };
    }
}

#[derive(Debug, Clone)]
#[repr(C)]
pub struct Label {
    pub(crate) text: *const libc::c_char,
    pub(crate) file_name: *const libc::c_char,
    pub(crate) color: Color2,
    pub(crate) span: Span,
}

#[derive(Debug, Clone)]
#[repr(C)]
pub struct BasicDiagnostic {
    pub(crate) c_file_name: *const libc::c_char,
    pub(crate) c_file_content: *const libc::c_char,
    pub(crate) c_labels: *const Label,
    pub(crate) c_labels_len: usize,
    pub(crate) c_kind: i32,
    pub(crate) c_error_code: i32,
    pub(crate) c_message: *const libc::c_char,
}

pub fn diag_kind_to_ariadne(kind: i32) -> ReportKind<'static> {
    match kind {
        1 => ReportKind::Error,
        2 => ReportKind::Warning,
        3 => ReportKind::Advice,
        _ => panic!("{} is a bad report type", kind),
    }
}

pub fn label_color_to_ariadne(color: Color) -> AColor {
    AColor::Rgb(color.r, color.g, color.b)
}
