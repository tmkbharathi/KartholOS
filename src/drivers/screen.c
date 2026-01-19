#include "screen.h"
#include "ports.h"

/* Declaration of private functions */
int get_cursor_offset();
void set_cursor_offset(int offset);
int print_char(char c, int col, int row, char attr);
int get_offset(int col, int row);
int get_offset_row(int offset);
int get_offset_col(int offset);

/**********************************************************
 * Public Kernel API functions
 **********************************************************/

/**
 * Print a message on the specified location
 * If col, row, are negative, we will use the current offset
 */
void print_at(char *message, int col, int row) {
  /* Update cursor if col and row are not negative */
  if (col >= 0 && row >= 0)
    set_cursor_offset(get_offset(col, row));

  int i = 0;
  while (message[i] != 0) {
    print_char(message[i++], col, row, WHITE_ON_BLACK);
  }
}

void print_string(char *message) { print_at(message, -1, -1); }

void clear_screen() {
  int screen_size = MAX_COLS * MAX_ROWS;
  int i;
  char *screen = (char *)VIDEO_ADDRESS;

  for (i = 0; i < screen_size; i++) {
    screen[i * 2] = ' ';
    screen[i * 2 + 1] = WHITE_ON_BLACK;
  }
  set_cursor_offset(get_offset(0, 0));
}

/**********************************************************
 * Private kernel functions
 **********************************************************/

/**
 * Innermost print function for our kernel, directly accesses the video memory
 *
 * If 'col' and 'row' are negative, we will print at current cursor location
 * If 'attr' is zero it will use 'white on black' as default
 * Returns the offset of the next character
 * Sets the video cursor to the returned offset
 */
int print_char(char c, int col, int row, char attr) {
  char *vidmem = (char *)VIDEO_ADDRESS;
  if (!attr)
    attr = WHITE_ON_BLACK;

  /* Error control: print a red 'E' if the coords aren't right */
  if (col >= MAX_COLS || row >= MAX_ROWS) {
    vidmem[2 * (MAX_COLS * MAX_ROWS) - 2] = 'E';
    vidmem[2 * (MAX_COLS * MAX_ROWS) - 1] = RED_ON_WHITE;
    return get_offset(col, row);
  }

  int offset;
  if (col >= 0 && row >= 0)
    offset = get_offset(col, row);
  else
    offset = get_cursor_offset();

  if (c == '\n') {
    int rows = offset / (2 * MAX_COLS);
    offset = get_offset(0, rows + 1);
  } else {
    vidmem[offset] = c;
    vidmem[offset + 1] = attr;
    offset += 2;
  }

  /* Check if the offset is over screen size and scroll */
  /* This part is simplified for now, we just wrap around or stop */
  if (offset >= MAX_ROWS * MAX_COLS * 2) {
    /* TODO: Implement scrolling */
    /* For now, just reset to 0 to avoid crashing/overflowing video memory */
    /* Alternatively, implement simple scrolling by copying lines up */
    int i;
    for (i = 1; i < MAX_ROWS; i++) {
      // Copy bytes from line i to i-1
      // memory_copy is not available yet, implementing manual copy
      char *src = (char *)VIDEO_ADDRESS + get_offset(0, i);
      char *dest = (char *)VIDEO_ADDRESS + get_offset(0, i - 1);
      for (int j = 0; j < MAX_COLS * 2; j++) {
        dest[j] = src[j];
      }
    }
    // Clear last line
    char *last_line = (char *)VIDEO_ADDRESS + get_offset(0, MAX_ROWS - 1);
    for (int j = 0; j < MAX_COLS * 2; j += 2) {
      last_line[j] = ' ';
      last_line[j + 1] = attr;
    }

    offset -= 2 * MAX_COLS;
  }

  set_cursor_offset(offset);
  return offset;
}

int get_cursor_offset() {
  /* Use the VGA ports to get the current cursor position
   * 1. Ask for high byte of the cursor offset (data 14)
   * 2. Ask for low byte (data 15)
   */
  port_byte_out(REG_SCREEN_CTRL, 14);
  int offset = port_byte_in(REG_SCREEN_DATA) << 8;
  port_byte_out(REG_SCREEN_CTRL, 15);
  offset += port_byte_in(REG_SCREEN_DATA);
  return offset * 2; /* Position * size of character cell */
}

void set_cursor_offset(int offset) {
  /* Similar to get_cursor_offset, but writing data */
  offset /= 2;
  port_byte_out(REG_SCREEN_CTRL, 14);
  port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset >> 8));
  port_byte_out(REG_SCREEN_CTRL, 15);
  port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset & 0xff));
}

int get_offset(int col, int row) { return 2 * (row * MAX_COLS + col); }
int get_offset_row(int offset) { return offset / (2 * MAX_COLS); }
int get_offset_col(int offset) {
  return (offset - (get_offset_row(offset) * 2 * MAX_COLS)) / 2;
}
