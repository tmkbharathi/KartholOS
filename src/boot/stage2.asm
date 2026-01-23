[org 0x7E00]
    jmp switch_to_pm

%include "src/boot/gdt.asm"
%include "src/boot/print_pm.asm"

[bits 16]
switch_to_pm:
    ; Enable A20 Line
    ; 1. Try BIOS method
    mov ax, 0x2401
    int 0x15

    ; 2. Try Fast A20 method (Port 0x92) as backup/reinforcement
    in al, 0x92
    or al, 2
    out 0x92, al

    cli                     ; 1. Disable interrupts
    lgdt [gdt_descriptor]   ; 2. Load the GDT descriptor
    
    mov eax, cr0
    or eax, 0x1             ; 3. Set 32-bit mode bit in CR0
    mov cr0, eax

    jmp CODE_SEG:init_pm    ; 4. Far jump to 32-bit code segment

[bits 32]
init_pm:
    mov ax, DATA_SEG        ; 5. Update segment registers
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000        ; 6. Update stack position so it is right at the top of the free space
    mov esp, ebp

    call BEGIN_PM           ; 7. Call the 32-bit main logic

BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm
    
    call 0x1000             ; Call the kernel entry point
    jmp $

MSG_PROT_MODE db "Successfully landed in 32-bit Protected Mode", 0

times 512-($-$$) db 0       ; Pad to 512 bytes
