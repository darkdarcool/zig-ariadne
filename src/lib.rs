// #![feature(str_from_utf16_endian)]
#![allow(unused_imports)]

use ariadne::{Color, ColorGenerator, Fmt, Label, Report, ReportKind, Source};
use std::ffi::{CStr, CString};

extern crate libc;

macro_rules! cstr_to_str {
    ($cstr:expr) => {
        unsafe { CStr::from_ptr($cstr) }.to_str().unwrap()
    };
}

/// Holy sigma
#[derive(Clone, Debug)]
#[repr(C)]
pub struct Span {
    start: usize,
    end: usize,
}

#[derive(Clone, Debug, Copy)]
#[repr(C)]
pub struct CColor {
    r: u8,
    g: u8,
    b: u8,
}

#[derive(Debug, Clone)]
#[repr(C)]
pub struct CLabel {
    text: *const libc::c_char,
    file_name: *const libc::c_char,
    color: CColor,
    span: Span,
}

fn diag_kind_to_ariadne(kind: i32) -> ReportKind<'static> {
    match kind {
        1 => ReportKind::Error,
        2 => ReportKind::Warning,
        3 => ReportKind::Advice,
        _ => panic!("{} is a bad report type", kind),
    }
}

fn label_color_to_ariadne(color: CColor) -> Color {
    Color::Rgb(color.r, color.g, color.b)
}

#[unsafe(no_mangle)]
pub extern "C" fn print_with_source_and_message(
    //file_name: *const libc::c_char,
    //file_nam: std::ffi::CString,
    c_file_name: *const libc::c_char,
    c_file_content: *const libc::c_char,
    c_labels: *const CLabel,
    c_labels_len: usize,
    c_kind: i32,
    c_error_code: i32,
    c_message: *const libc::c_char,
) {
    let file_name = cstr_to_str!(c_file_name);
    let file_content = cstr_to_str!(c_file_content);
    let message = cstr_to_str!(c_message);

    let kind = diag_kind_to_ariadne(c_kind);
    //let message = cstr_to_str!(c_message);
    let labels: Vec<CLabel> =
        unsafe { std::slice::from_raw_parts(c_labels, c_labels_len).to_vec() };

    let mut report = Report::build(kind, (file_name, 1..2))
        .with_code(c_error_code)
        .with_message(message);

    for label in labels.iter() {
        let text = cstr_to_str!(label.text);
        let label_file_name = cstr_to_str!(label.file_name);
        let color = label_color_to_ariadne(label.color);

        report = report.with_label(
            Label::new((label_file_name, label.span.start..label.span.end))
                .with_message(text)
                .with_color(color),
        );
    }

    report
        .finish()
        .print((file_name, Source::from(file_content)))
        .unwrap();
    /*
            .with_label(
                Label::new((file_name, 5..10))
                    .with_message(message)
                    .with_color(Color::Red),
            )
            .finish()
            .print((file_name, Source::from(file_content)))
            .unwrap();
    */
}
