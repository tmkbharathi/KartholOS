#include "mem.h"
#include "stdio.h" // For debugging if needed

/*
 * Simple First-Fit Heap Allocator
 *
 * We use a linked list of memory blocks.
 * The heap starts at 0x100000 (1MB) to be safe above the kernel.
 *
 * Block structure:
 *  - size: Size of the data part
 *  - is_free: 1 if free, 0 if used
 *  - next: Pointer to next block
 */

typedef struct mem_block {
  size_t size;
  int is_free;
  struct mem_block *next;
} mem_block_t;

#define HEAP_START_ADDR 0x100000
#define HEAP_MAX_SIZE 0x100000 // 1MB heap size for now

mem_block_t *heap_head = NULL;

// memory_copy and memory_set removed (use string.h equivalents)

void malloc_init() {
  heap_head = (mem_block_t *)HEAP_START_ADDR;
  heap_head->size = HEAP_MAX_SIZE - sizeof(mem_block_t);
  heap_head->is_free = 1;
  heap_head->next = NULL;
}

void *malloc(size_t size) {
  mem_block_t *current = heap_head;

  while (current != NULL) {
    if (current->is_free && current->size >= size) {
      // Found a block
      // Check if we can split it
      if (current->size > size + sizeof(mem_block_t)) {
        mem_block_t *new_block =
            (mem_block_t *)((uint8_t *)current + sizeof(mem_block_t) + size);
        new_block->size = current->size - size - sizeof(mem_block_t);
        new_block->is_free = 1;
        new_block->next = current->next;

        current->size = size;
        current->next = new_block;
      }

      current->is_free = 0;
      return (void *)((uint8_t *)current + sizeof(mem_block_t));
    }
    current = current->next;
  }

  return NULL; // Out of memory
}

void free(void *ptr) {
  if (ptr == NULL)
    return;

  // Get the block header
  mem_block_t *block = (mem_block_t *)((uint8_t *)ptr - sizeof(mem_block_t));
  block->is_free = 1;

  // Merge with next block if free
  if (block->next != NULL && block->next->is_free) {
    block->size += block->next->size + sizeof(mem_block_t);
    block->next = block->next->next;
  }

  // Note: A full implementation would also merge with previous block
  // but that requires a doubly linked list or traversal.
  // Keeping it simple for now.
}
