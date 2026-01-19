void kernel_main() {
    // Pointer to video memory
    char* video_memory = (char*) 0xb8000;
    // Write 'X' to the first 80 characters (one line)
    for (int i = 0; i < 80; i++) {
        *(video_memory + i * 2) = 'X';
        *(video_memory + i * 2 + 1) = 0x0f; // White on Black
    }
}
