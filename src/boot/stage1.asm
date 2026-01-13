[org 0x7C00]                 ; Tell assembler that BIOS loads this code at 0x7C00
bits 16                      ; BIOS starts execution in 16-bit real mode

xor ax, ax                   ; AX = 0
mov ds, ax                   ; Set Data Segment to 0 so DS:BX points correctly
mov ss, ax                   ; Set Stack Segment to 0 for safe stack operations
mov sp, 0x8000               ; Initialize Stack Pointer at 0x8000 (safe area)
mov [BOOT_DRIVE], dl         ; BIOS stores boot drive in DL, save it

mov bx, HelloString           ; Load address of the string into BX
call print_string             ; Call function to print the string

mov bx, LoadingMsg
call print_string

; Reset Disk System
mov ah, 0
mov dl, [BOOT_DRIVE]
int 0x13
jc disk_error

; Read Second Stage from Disk
mov ah, 0x02        ; BIOS read sector function
mov al, 1           ; Read 1 sector
mov ch, 0           ; Cylinder 0
mov dh, 0           ; Head 0
mov cl, 2           ; Sector 2 (Sector 1 is bootloader)
mov dl, [BOOT_DRIVE] ; Drive number
mov bx, 0x7E00      ; Load to 0x7E00
int 0x13
jc disk_error

jmp 0x7E00          ; Jump to second stage

disk_error:
    mov bx, DiskErrorMsg
    call print_string
    jmp $

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

BOOT_DRIVE: db 0
HelloString:
    db 'KartholOS Boot...', 13, 10, 0
LoadingMsg:
    db 'Loading Stage 2...', 13, 10, 0
DiskErrorMsg:
    db 'Disk Read Error!', 0

times 510-($-$$) db 0         ; Pad remaining bytes with zeros up to 510 bytes
dw 0xAA55                     ; Boot signature required by BIOS
