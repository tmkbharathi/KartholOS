#include "../drivers/screen.h"

void kernel_main() {
  clear_screen();
  print_string("Hello from Kernel!\n");
  print_string("Welcome to KartholOS.\n");
  print_string("This is running in 32-bit Protected Mode.");
}
