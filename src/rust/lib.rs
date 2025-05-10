// #![feature(str_from_utf16_endian)]
#![allow(unused_imports)]

use ariadne::{Color, ColorGenerator, Fmt, Label, Report, ReportKind, Source};
use std::ffi::{CStr, CString};

extern crate libc;

pub mod interop;

use interop::{
    BasicDiagnostic, Color2, Label as CLabel, cstr_to_str, diag_kind_to_ariadne,
    label_color_to_ariadne,
};

#[unsafe(no_mangle)]
pub extern "C" fn test_color(c: Color2) {
    let ariadne_color: Color = c.into();
    println!("{:#?}", ariadne_color);
}

/// Print a basic diagnostic
#[unsafe(no_mangle)]
pub extern "C" fn print_basic_diagnostic(
    //file_name: *const libc::c_char,
    //file_nam: std::ffi::CString,
    // c_file_name: *const libc::c_char,
    // c_file_content: *const libc::c_char,
    // c_labels: *const CLabel,
    // c_labels_len: usize,
    // c_kind: i32,
    // c_error_code: i32,
    // c_message: *const libc::c_char,
    diagnostic: BasicDiagnostic,
) {
    let file_name = cstr_to_str!(diagnostic.c_file_name);
    let file_content = cstr_to_str!(diagnostic.c_file_content);
    let message = cstr_to_str!(diagnostic.c_message);

    let kind = diag_kind_to_ariadne(diagnostic.c_kind);
    //let message = cstr_to_str!(c_message);
    let labels: Vec<CLabel> = unsafe {
        std::slice::from_raw_parts(diagnostic.c_labels, diagnostic.c_labels_len).to_vec()
    };

    let mut report = Report::build(kind, (file_name, 1..2))
        .with_code(diagnostic.c_error_code)
        .with_message(message);

    for label in labels.iter() {
        let text = cstr_to_str!(label.text);
        let label_file_name = cstr_to_str!(label.file_name);
        //let color = label_color_to_ariadne(label.color);

        report = report.with_label(
            Label::new((label_file_name, label.span.start..label.span.end))
                .with_message(text)
                .with_color(label.color.into()),
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
