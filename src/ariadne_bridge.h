#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef enum Color2_Tag {
  Primary,
  Rgb,
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
} Color2_Tag;

typedef struct Rgb_Body {
  uint8_t _0;
  uint8_t _1;
  uint8_t _2;
} Rgb_Body;

typedef struct Color2 {
  Color2_Tag tag;
  union {
    Rgb_Body rgb;
  };
} Color2;

/**
 * Holy sigma
 */
typedef struct Span {
  uintptr_t start;
  uintptr_t end;
} Span;

typedef struct Label {
  const char *text;
  const char *file_name;
  struct Color2 color;
  struct Span span;
} Label;

typedef struct BasicDiagnostic {
  const char *c_file_name;
  const char *c_file_content;
  const struct Label *c_labels;
  uintptr_t c_labels_len;
  int32_t c_kind;
  int32_t c_error_code;
  const char *c_message;
} BasicDiagnostic;

void test_color(struct Color2 c);

/**
 * Print a basic diagnostic
 */
void print_basic_diagnostic(struct BasicDiagnostic diagnostic);
