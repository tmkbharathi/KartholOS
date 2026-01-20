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

    // Use backspace to erase the character
    print_string("\b");
  }

  clear_screen();
}
