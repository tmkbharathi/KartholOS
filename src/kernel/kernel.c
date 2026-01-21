#include "../drivers/screen.h"
#include "../libc/stdio.h"
#include "splash.h"


void kernel_main() {
  show_splash();
  clear_screen();
  print_string("Hello from Kernel!\n");
  print_string("Welcome to KartholOS.\n");
  print_string("This is running in 32-bit Protected Mode.\n");

  printf("Testing printf: %d, %x, %s\n", 42, 0x1234, "Success!");
}
