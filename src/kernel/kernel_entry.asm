[bits 32]
[extern _kernel_main] ; Define calling point. Must have same name as kernel.c 'kernel_main' function (prefixed with _ on Windows)
global _start ; This is the entry point that the linker will look for

_start:
    call _kernel_main ; Invoke kernel_main() in our C kernel
    jmp $     ; Hang forever when we return
