# Compilers and tools
ASM = nasm
CC = gcc
LD = ld

# Flags
ASMFLAGS_BIN = -f bin
ASMFLAGS_ELF = -f elf32
CFLAGS = -m32 -ffreestanding -fno-pie -nostdlib -nostdinc -fno-builtin -fno-stack-protector
LDFLAGS = -m elf_i386 -T linker.ld

# Directories
BOOT_DIR = boot
KERNEL_DIR = kernel
BUILD_DIR = build
DRIVERS_DIR = drivers
LIB_DIR = lib

# Source files
BOOTLOADER_SRC = $(BOOT_DIR)/bootloader.asm
KERNEL_ENTRY_SRC = $(KERNEL_DIR)/kernel_entry.asm
KERNEL_C_SRC = $(KERNEL_DIR)/kernel.c

# Output files
BOOTLOADER_BIN = $(BUILD_DIR)/bootloader.bin
KERNEL_ENTRY_OBJ = $(BUILD_DIR)/kernel_entry.o
KERNEL_C_OBJ = $(BUILD_DIR)/kernel.o
KERNEL_BIN = $(BUILD_DIR)/kernel.bin
OS_IMG = $(BUILD_DIR)/os.img

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Default target
all: $(OS_IMG)

# Build bootloader
$(BOOTLOADER_BIN): $(BOOTLOADER_SRC) $(BOOT_DIR)/*.asm | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS_BIN) -I$(BOOT_DIR) $(BOOTLOADER_SRC) -o $(BOOTLOADER_BIN)

# Build kernel entry (ASM)
$(KERNEL_ENTRY_OBJ): $(KERNEL_ENTRY_SRC) | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS_ELF) $< -o $@

# Build kernel (C)
$(KERNEL_C_OBJ): $(KERNEL_C_SRC) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Link kernel
$(KERNEL_BIN): $(KERNEL_ENTRY_OBJ) $(KERNEL_C_OBJ) linker.ld | $(BUILD_DIR)
	$(LD) $(LDFLAGS) -o $@ $(KERNEL_ENTRY_OBJ) $(KERNEL_C_OBJ)

# Extract raw binary from ELF kernel
$(BUILD_DIR)/kernel_raw.bin: $(KERNEL_BIN)
	objcopy -O binary $< $@

# Create OS image
$(OS_IMG): $(BOOTLOADER_BIN) $(BUILD_DIR)/kernel_raw.bin
	dd if=/dev/zero of=$@ bs=512 count=2880 2>/dev/null
	dd if=$(BOOTLOADER_BIN) of=$@ conv=notrunc bs=512 count=1 2>/dev/null
	dd if=$(BUILD_DIR)/kernel_raw.bin of=$@ conv=notrunc bs=512 seek=1 2>/dev/null

# Run in QEMU
run: $(OS_IMG)
	qemu-system-i386 -fda $(OS_IMG)

# Clean
clean:
	rm -rf $(BUILD_DIR)

# Debug
debug: $(OS_IMG)
	qemu-system-i386 -fda $(OS_IMG) -s -S

# Install (copy to a USB or floppy)
install: $(OS_IMG)
	@echo "Copy $(OS_IMG) to your boot device"

# Show build info
info:
	@echo "OS-1 Build Information:"
	@echo "Bootloader: $(BOOTLOADER_SRC)"
	@echo "Kernel Entry: $(KERNEL_ENTRY_SRC)"
	@echo "Kernel C: $(KERNEL_C_SRC)"
	@echo "Output: $(OS_IMG)"

.PHONY: all run clean debug install info