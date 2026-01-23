#include "../drivers/screen.h"
#include "../libc/mem.h"
#include "../libc/stdio.h"
#include "../libc/string.h"
#include "splash.h"

void kernel_main() {
  show_splash();
  clear_screen();
  print_string("Hello from Kernel!\n");
  print_string("Welcome to KartholOS.\n");
  print_string("This is running in 32-bit Protected Mode.\n");

  printf("Testing printf: %d, %x, %s\n", 42, 0x1234, "Success!");

  // Heap Initialization
  print_string("Initializing Heap...\n");
  malloc_init();

  // Malloc Test
  print_string("Allocating memory...\n");
  char *ptr = (char *)malloc(128);
  if (ptr != NULL) {
    strcpy(ptr, "Dynamic Memory Allocation Works!");
    printf("Malloc test: %s\n", ptr);
    printf("Address: %x\n", (uint32_t)ptr);

    free(ptr);
    print_string("Free test successful.\n");
  } else {
    print_string("Malloc failed!\n");
  }
}
