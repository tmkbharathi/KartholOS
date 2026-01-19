#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("Usage: %s <file>\n", argv[0]);
        return 1;
    }

    FILE* f = fopen(argv[1], "ab");
    if (!f) {
        perror("Error opening file");
        return 1;
    }

    fseek(f, 0, SEEK_END);
    long size = ftell(f);
    long target_size = 1440 * 1024; // 1.44 MB

    if (size < target_size) {
        long bytes_to_write = target_size - size;
        char* buffer = (char*)calloc(bytes_to_write, 1); // calloc initializes to 0
        if (!buffer) {
            perror("Memory allocation failed");
            fclose(f);
            return 1;
        }
        fwrite(buffer, 1, bytes_to_write, f);
        free(buffer);
        printf("Padded %ld bytes to reach 1.44MB.\n", bytes_to_write);
    } else {
        printf("File is already larger than or equal to 1.44MB. No padding needed.\n");
    }

    fclose(f);
    return 0;
}
