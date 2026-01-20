# Tools
ASM = nasm
CC = gcc
LD = ld
OBJCOPY = objcopy
QEMU = qemu-system-x86_64

# Directories
SRC_DIR = src
BUILD_DIR = build
BOOT_DIR = $(SRC_DIR)/boot
KERNEL_DIR = $(SRC_DIR)/kernel
DRIVERS_DIR = $(SRC_DIR)/drivers

# Output
TARGET = $(BUILD_DIR)/os-image.bin

# Sources using wildcards
KERNEL_SOURCES = $(wildcard $(KERNEL_DIR)/*.c)
DRIVERS_SOURCES = $(wildcard $(DRIVERS_DIR)/*.c)
C_SOURCES = $(KERNEL_SOURCES) $(DRIVERS_SOURCES)

# Object files (mirroring source structure in build dir)
# e.g., src/kernel/main.c -> build/kernel/main.o
OBJ = $(C_SOURCES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)

# Kernel Entry Object (Must be first)
KERNEL_ENTRY = $(BUILD_DIR)/kernel/kernel_entry.o

# Default target
all: $(TARGET)

# Create build subdirectories
$(BUILD_DIR)/kernel $(BUILD_DIR)/drivers:
	@mkdir -p $@

# Compile C sources (Generic rule)
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) -ffreestanding -m32 -g -c $< -o $@

# Assemble Kernel Entry
$(KERNEL_ENTRY): $(KERNEL_DIR)/kernel_entry.asm
	@mkdir -p $(dir $@)
	$(ASM) -f win32 $< -o $@

# Assemble Stage 1
$(BUILD_DIR)/stage1.bin: $(BOOT_DIR)/stage1.asm
	@mkdir -p $(dir $@)
	$(ASM) -f bin $< -o $@

# Assemble Stage 2
$(BUILD_DIR)/stage2.bin: $(BOOT_DIR)/stage2.asm
	@mkdir -p $(dir $@)
	$(ASM) -f bin $< -o $@

# Tool: Pad
$(BUILD_DIR)/pad.exe: src/misc/pad.c
	@mkdir -p $(dir $@)
	$(CC) $< -o $@

# Link Kernel
$(BUILD_DIR)/kernel.bin: $(KERNEL_ENTRY) $(OBJ)
	$(LD) -o $@.tmp -Ttext 0x1000 $^ 
	$(OBJCOPY) -O binary $@.tmp $@
	rm $@.tmp

# Create OS Image
$(TARGET): $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin $(BUILD_DIR)/kernel.bin $(BUILD_DIR)/pad.exe
	cat $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin $(BUILD_DIR)/kernel.bin > $@
	$(BUILD_DIR)/pad.exe $@

# Run
run: $(TARGET)
	$(QEMU) -drive format=raw,file=$(TARGET)

# Clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean
