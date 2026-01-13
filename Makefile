# Tools
ASM = nasm
QEMU = qemu-system-x86_64

# Paths
SRC_DIR = src/boot
BUILD_DIR = build
TARGET = $(BUILD_DIR)/boot.bin

# Default target
all: $(TARGET)

# Create build dir and compile
$(TARGET): $(SRC_DIR)/boot.asm
	@mkdir -p $(BUILD_DIR)
	$(ASM) -f bin $< -o $@

# Run the OS
run: $(TARGET)
	$(QEMU) -drive format=raw,file=$(TARGET)

# Clean up
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean
