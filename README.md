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
│   └── boot.bin
└── src
    └── boot
        └── boot.asm
```

---

## Bootloader Overview

The bootloader performs the following steps:

1. Starts execution at memory address `0x7C00` (BIOS standard).
2. Runs in **16-bit real mode**.
3. Initializes segment registers and stack.
4. Prints `Hello, World!` using BIOS interrupt `INT 0x10`.
5. Enters an infinite loop.
6. Ends with the mandatory boot signature `0xAA55`.

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
build/boot.bin
```

---

## Run

To run the bootloader in QEMU:

```
make run
```

You should see:

```
Hello, World!
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

- Single-stage bootloader
- BIOS-only (no UEFI support)
- 16-bit real mode only
- No kernel or filesystem
- No hardware abstraction

---

## Learning Goals

- Understand the BIOS boot process
- Learn x86 real-mode assembly
- Understand boot sector layout (512-byte constraint)
- Prepare for multi-stage OS development
- Build foundation knowledge for kernel development

---

## Next Steps

- Add a second-stage bootloader
- Load code beyond 512 bytes
- Switch to protected mode
- Implement a minimal kernel
- Add basic screen and keyboard drivers

---

## License

This project is provided for educational purposes.  
You are free to use, modify, and distribute it.