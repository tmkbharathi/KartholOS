[org 0x7C00]                 ; Tell assembler that BIOS loads this code at 0x7C00
bits 16                      ; BIOS starts execution in 16-bit real mode

xor ax, ax                   ; AX = 0
mov ds, ax                   ; Set Data Segment to 0 so DS:BX points correctly
mov ss, ax                   ; Set Stack Segment to 0 for safe stack operations
mov sp, 0x8000               ; Initialize Stack Pointer at 0x8000 (safe area)

mov bx, HelloString           ; Load address of the string into BX
call print_string             ; Call function to print the string

jmp $                         ; Infinite loop to prevent falling into memory

print_string:
    mov ah, 0x0E              ; BIOS video service: teletype output function

.loop:
    mov al, [bx]              ; Load current character from DS:BX into AL
    cmp al, 0                 ; Check for null terminator (end of string)
    je .done                  ; If zero, exit the function
    int 0x10                  ; BIOS interrupt to print character in AL
    inc bx                    ; Move to next character in the string
    jmp .loop                 ; Repeat for next character

.done:
    ret                       ; Return to caller using address from stack

HelloString:
    db 'Hello, World!', 0     ; Null-terminated ASCII string

times 510-($-$$) db 0         ; Pad remaining bytes with zeros up to 510 bytes
dw 0xAA55                     ; Boot signature required by BIOS
