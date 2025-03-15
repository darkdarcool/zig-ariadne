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

#[derive(Debug, Clone)]
#[repr(C)]
pub struct Label {
    pub(crate) text: *const libc::c_char,
    pub(crate) file_name: *const libc::c_char,
    pub(crate) color: Color,
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
