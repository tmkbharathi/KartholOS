# Tools
ASM = nasm
CC = gcc
LD = ld
OBJCOPY = objcopy
QEMU = qemu-system-x86_64



# Paths
SRC_DIR = src/boot
KERNEL_DIR = src/kernel
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

# Kernel
$(BUILD_DIR)/kernel_entry.o: $(KERNEL_DIR)/kernel_entry.asm
	$(ASM) -f win32 $< -o $@

$(BUILD_DIR)/kernel.o: $(KERNEL_DIR)/kernel.c
	$(CC) -ffreestanding -m32 -g -c $< -o $@

$(BUILD_DIR)/kernel.bin: $(BUILD_DIR)/kernel_entry.o $(BUILD_DIR)/kernel.o
	$(LD) -o $@.tmp -Ttext 0x1000 $^ 
	$(OBJCOPY) -O binary $@.tmp $@
	rm $@.tmp

# Tools to build
$(BUILD_DIR)/pad.exe: src/misc/pad.c
	$(CC) $< -o $@

$(TARGET): $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin $(BUILD_DIR)/kernel.bin $(BUILD_DIR)/pad.exe
	cat $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin $(BUILD_DIR)/kernel.bin > $@
	$(BUILD_DIR)/pad.exe $@




# Run the OS
run: $(TARGET)
	$(QEMU) -drive format=raw,file=$(TARGET)

# Clean up
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean
