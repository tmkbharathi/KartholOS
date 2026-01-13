# Tools
ASM = nasm
QEMU = qemu-system-x86_64

# Paths
SRC_DIR = src/boot
BUILD_DIR = build
TARGET = $(BUILD_DIR)/os-image.bin

# Default target
all: $(TARGET)

# Create build dir and compile
$(BUILD_DIR)/stage1.bin: $(SRC_DIR)/stage1.asm
	@mkdir -p $(BUILD_DIR)
	$(ASM) -f bin $< -o $@

$(BUILD_DIR)/stage2.bin: $(SRC_DIR)/stage2.asm
	$(ASM) -f bin $< -o $@

$(TARGET): $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin
	cat $^ > $@

# Run the OS
run: $(TARGET)
	$(QEMU) -drive format=raw,file=$(TARGET)

# Clean up
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean
