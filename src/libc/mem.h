#ifndef MEM_H
#define MEM_H

#include <stddef.h>
#include <stdint.h>

// Use memcpy/memset from string.h instead

void malloc_init();
void *malloc(size_t size);
void free(void *ptr);

#endif
