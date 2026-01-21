#include "stdio.h"
#include "../drivers/screen.h"
#include "string.h"

void putchar(char c) {
  char str[2] = {c, '\0'};
  print_string(str);
}

void puts(char *s) {
  print_string(s);
  putchar('\n');
}

void printf(char *format, ...) {
  va_list args;
  va_start(args, format);

  for (int i = 0; format[i] != '\0'; i++) {
    if (format[i] == '%') {
      i++;
      switch (format[i]) {
      case 'd': {
        int arg = va_arg(args, int);
        char str[16];
        itoa(arg, str);
        print_string(str);
        break;
      }
      case 's': {
        char *arg = va_arg(args, char *);
        print_string(arg);
        break;
      }
      case 'c': {
        char arg = (char)va_arg(args, int);
        putchar(arg);
        break;
      }
      case 'x': {
        int arg = va_arg(args, int);
        char str[16];
        hex_to_ascii(arg, str);
        print_string(str);
        break;
      }
      default:
        putchar('%');
        putchar(format[i]);
      }
    } else {
      putchar(format[i]);
    }
  }

  va_end(args);
}
