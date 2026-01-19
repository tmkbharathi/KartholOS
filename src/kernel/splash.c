#include "splash.h"
#include "../drivers/screen.h"

void delay(int count) {
  volatile int i = 0;
  while (i < count) {
    i++;
  }
}

void show_splash() {
  clear_screen();

  // Simple Centered Logo
  // Screen is 80 chars wide.
  // Logo width approx 30 chars -> offset approx 25

  // Vertical padding
  for (int i = 0; i < 8; i++)
    print_string("\n");

  print_string(
      "                       _  __          _   _           _  ___  ____  \n");
  print_string("                      | |/ /__ _ _ __| |_| |__   ___ | |/ _ "
               "\\/ ___| \n");
  print_string("                      | ' // _` | '__| __| '_ \\ / _ \\| | | | "
               "\\___ \\ \n");
  print_string("                      | . \\ (_| | |  | |_| | | | (_) | | |_| "
               "|___) |\n");
  print_string("                      |_|\\_\\__,_|_|   \\__|_| "
               "|_|\\___/|_|\\___/|____/ \n");

  print_string("\n\n");
  print_string("                                     Loading... ");

  // Loading Circle Animation
  char spinner[] = {'|', '/', '-', '\\'};
  int spinner_chars = 4;

  // Run animation for some time
  for (int i = 0; i < 20; i++) {
    char anim_char[2];
    anim_char[0] = spinner[i % spinner_chars];
    anim_char[1] = '\0';

    print_string(anim_char);

    // Wait
    delay(40000000);

    // Backspace equivalent: move cursor back one char
    // Since we don't have backspace support in print_string yet,
    // we can cheat by printing a backspace char if driver supported it,
    // or just use print_at if we tracked position.
    // For simplicity in this driver, let's just use print_at relative to
    // current pos? Actually, our driver doesn't expose "get current pos" easily
    // to C api yet except implicitly. Let's implement a simple cheat: print,
    // wait, then print backspace ch (0x08) Note: Our currently implemented
    // print_char does NOT handle backspace (0x08). Let's rely on print_at.

    // Hardcoded position for the spinner:
    // "Loading... " is 11 chars.
    // Centered roughly:
    // "                                     Loading... " -> 37 spaces + 11
    // chars = 48 So spinner is at col 48. Row: 8 (padding) + 5 (logo) + 2
    // (newlines) = 15 approx. Let's just assume we are at the right place.
    // Better way: use print_at with explicit coordinates for the spinner.

    // Row 15 (0-indexed), Col 48
    print_at(anim_char, 48, 15);
  }

  clear_screen();
}
