# KartholOS

KartholOS is a minimal x86 bootloader-based operating system project created for learning and experimentation with low-level system programming.  
The current implementation demonstrates a BIOS-based boot sector written in 16-bit x86 assembly, which prints a message to the screen using BIOS interrupts.

This project is intentionally simple and educational, serving as the foundation for building a custom operating system from scratch.

---

## Project Structure

```
KartholOS
├── Makefile
├── README.md
├── build
│   └── os-image.bin
└── src
    ├── boot
    │   ├── gdt.asm
    │   ├── print_pm.asm
    │   ├── stage1.asm
    │   └── stage2.asm
    ├── drivers
    │   ├── ports.c
    │   ├── ports.h
    │   ├── screen.c
    │   └── screen.h
    ├── kernel
    │   ├── kernel.c
    │   ├── kernel_entry.asm
    │   ├── splash.c
    │   └── splash.h
    ├── libc
    │   ├── mem.c
    │   ├── mem.h
    │   ├── stdio.c
    │   ├── stdio.h
    │   ├── string.c
    │   └── string.h
    └── misc
        └── pad.c
```

---

## Bootloader Overview

The bootloader performs the following steps:

1. **Stage 1**: Starts at `0x7C00`, resets disk, loads Stage 2, and jumps to it.
2. **Stage 2**:
   - Enables **A20 Line** (Critical for assessing memory > 1MB).
   - Loads the **GDT** (Global Descriptor Table).
   - Switches to **32-bit Protected Mode**.
   - Prints a success message to video memory (`0xb8000`).
   - Hangs (infinite loop) waiting for a kernel.

---

## Kernel & Drivers

### C Kernel
The kernel entry point is `kernel_main()` (in `src/kernel/kernel.c`). It currently:
- Initializes the video driver.
- Initializes the **Heap Manager**.
- Clears the screen.
- Prints welcome messages to indicate successful protected mode entry.

### VGA Screen Driver
Located in `src/drivers/screen.c`:
- **Video Memory**: Directly writes to `0xb8000` VGA buffer.
- **Port I/O**: Uses inline assembly (`in`/`out`) to communicate with screen control ports (`0x3d4`, `0x3d5`) for cursor management.
- **Scrolling**: Automatically scrolls text up when the screen fills.
- **Printing**: Supports basic string and character printing with correct cursor updates.

### Boot Splash Screen
Located in `src/kernel/splash.c`:
- **ASCII Art**: Displays a custom "KartholOS" logo on boot.
- **Animation**: Shows a spinning loading indicator.
- **Implementation**: Uses a simple busy-wait delay loop to create the animation effect before clearing the screen for the main kernel.

### Standard Library (Libc)
Located in `src/libc`:
- **stdio**: Implements `printf`, `puts`, `putchar`.
  - Supports format specifiers: `%d` (int), `%x` (hex), `%s` (string), `%c` (char).
- **string**: Implements common string and memory functions:
  - `memcpy`, `memset`, `strlen`, `strcpy`, `strcmp`, `strcat`, `reverse`, `atoi`, `itoa`.
- **mem**: Implements **Heap Manager**:
  - `malloc`, `free`.
  - Simple Linked-List First-Fit Allocator.

---

## Prerequisites

You need the following tools installed depending on your operating system.

### Windows

- **NASM**  
  Download from: https://www.nasm.us  
  Ensure `nasm.exe` is added to your system `PATH`.

- **QEMU for Windows**  
  Download from: https://www.qemu.org/download/#windows  
  During installation, enable system-wide PATH support if available.

- **Make (Optional but Recommended)**  
  - Install via **MSYS2**, **Git Bash**, or **WSL**
  - Alternatively, run NASM and QEMU commands manually without `make`

Recommended environment:
- Windows + **WSL (Ubuntu)** for a Linux-like workflow

---

### macOS

```
brew install nasm qemu
```

---

### Ubuntu / Debian (Linux)

```
sudo apt update
sudo apt install nasm qemu-system-x86
```

---

## Build

From the project root:

```
make
```

This will generate:

```
build/os-image.bin
```

---

## Run

To run the bootloader in QEMU:

```
make run
```

You should see:

```
Testing printf: 42, 1234, Success!
```

printed in the emulator window.

---

## Clean

Remove generated build artifacts:

```
make clean
```

---

## Current Limitations

- No filesystem
- No hardware abstraction (Keyboard, etc.)
- No paging (Virtual Memory)
- No user space (Ring 3)

---

## Learning Goals

- Understand the BIOS boot process
- Learn x86 real-mode assembly
- Understand boot sector layout (512-byte constraint)
- Implement multi-stage booting
- Read data from disk using BIOS interrupts

---

## Completed Milestones

- [x] Create a bootable disk image
- [x] Print text using BIOS interrupts
- [x] Implement First Stage Bootloader (512 bytes)
- [x] Implement Second Stage Bootloader
- [x] Load code from disk beyond the 512-byte limit
- [x] Switch to 32-bit Protected Mode (GDT, VGA Driver)
- [x] Implement a minimal **C Kernel**
- [x] Implement **VGA Screen Driver** (Basic string printing, scrolling)
- [x] Implement **Boot Splash Screen** (ASCII Logo, Loading Animation)
- [x] Implement **Standard Library (Libc)** (`printf`, `memcpy`, strings)
- [x] Implement **Heap Manager** (`malloc`, `free`)

---

## Next Steps

- **Interrupts (IDT)**: Handle hardware interrupts (keyboard, timer).
- **Keyboard Driver**: Read input from the user.
- **64-bit Long Mode**: Switch from 32-bit Protected Mode to 64-bit.
- **Paging**: Implement Virtual Memory.

---

## Recent Changes (Refactoring & Fixes)

### 1. Heap Manager Implementation
- **malloc/free**: Implemented a basic memory allocator in `src/libc/mem.c`.
- **Integration**: Initialized in `kernel.c` to allow dynamic memory usage.

### 2. A20 Line Fix (Critical Debugging)
- **Issue**: Converting to Protected Mode and accessing memory above 1MB (e.g., `0x100000` for the Heap) caused a crash/reboot loop or silent failure.
- **Root Cause**: The **A20 Line** was disabled by default.
  - In legacy x86 mode, address `0x100000` wraps around to `0x00000` if the A20 line is off.
  - Writing to the heap (`0x100000`) was unknowingly modifying the **IVT (Interrupt Vector Table)** and BIOS data area at `0x00000`, crashing the system.
- **Fix**: Added A20 enablement code in `src/boot/stage2.asm`:
  - **Method 1**: BIOS Interrupt `0x15` function `0x2401`.
  - **Method 2**: Fallback to **Fast A20** (Port `0x92`) if BIOS fails.

### 3. Standard Library Implementation
- **stdio.h/c**: Added `printf` implementation interacting with the screen driver.
- **string.h/c**: Added essential string and memory operations.
- **Makefile Update**: Included `src/libc` in the compilation process.

### 4. Build System (Makefile)
- **Dynamic Source Discovery**: Replaced manual file listing with `wildcard` functions.
  - Automatically detects and compiles all `.c` files in `src/kernel/`, `src/drivers/`, and `src/libc/`.
  - Simplifies adding new files (no need to edit Makefile).
- **Clean Output**: Object files are now organized in `build/kernel` and `build/drivers` mirroring the source tree.

### 5. Bootloader (Stage 1)
- **LBA Disk Reading**: Replaced hardcoded "chunk-based" reading with a robust **LBA-to-CHS** loop.
  - Can now read kernels of any size (currently set to 50 sectors) without worrying about cylinder/head boundaries.
- **Bug Fixes**:
  - **Head Selection**: Fixed a critical bug where the bootloader was reading from Head 1 instead of Head 0 for Stage 2.
  - **Segment Initialization**: Added explicit initialization of `DS`, `ES`, `SS`, `SP` to ensure safe memory access.
  - **Drive ID**: Removed forced Drive ID (was `dl=0`), now correctly using the BIOS-provided Boot Drive ID.

### 6. Drivers & UI
- **Screen Driver**: Implemented **Backspace (`\b`)** support.
  - `0x08` character now moves the cursor back and erases the character (destructive backspace).
- **Splash Screen**: Updated the spinner animation to use `\b` for smoother, coordinate-independent rendering.

---

## License

This project is provided for educational purposes.  
You are free to use, modify, and distribute it.