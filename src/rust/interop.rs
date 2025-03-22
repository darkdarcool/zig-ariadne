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
    Primary,
    Fixed(u8),
    Rgb(u8, u8, u8),
    Black,
    Red,
    Green,
    Yellow,
    Blue,
    Magenta,
    Cyan,
    White,
    BrightBlack,
    BrightRed,
    BrightGreen,
    BrightYellow,
    BrightBlue,
    BrightMagenta,
    BrightCyan,
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
