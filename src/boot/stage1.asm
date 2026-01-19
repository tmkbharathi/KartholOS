[org 0x7C00]                 ; Tell assembler that BIOS loads this code at 0x7C00
bits 16                      ; BIOS starts execution in 16-bit real mode

xor ax, ax                   ; AX = 0
mov ds, ax                   ; Set Data Segment to 0 so DS:BX points correctly
mov ss, ax                   ; Set Stack Segment to 0 for safe stack operations
mov es, ax                   ; Set Extra Segment to 0 (Critical for BIOS disk reads)
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
mov al, 1           ; Read 1 sector (Stage 2)
mov ch, 0           ; Cylinder 0
mov dh, 0           ; Head 0
mov cl, 2           ; Start from Sector 2
mov dl, [BOOT_DRIVE] ; Drive number
mov bx, 0x7E00      ; Load to 0x7E00
int 0x13
jc disk_error

; Read Kernel - Chunk 1
mov ah, 0x0e
mov al, '1'
int 0x10

mov ah, 0x02
mov al, 15          ; Read 15 sectors
mov ch, 0
mov dh, 0
mov cl, 3           ; Start Sector 3
mov dl, [BOOT_DRIVE]
mov bx, 0x1000      ; Dest 0x1000
int 0x13
jc disk_error

; Read Kernel - Chunk 2
mov ah, 0x0e
mov al, '2'
int 0x10

mov ah, 0x02
mov al, 18
mov ch, 0
mov dh, 1           ; Head 1
mov cl, 1           ; Sector 1
mov dl, [BOOT_DRIVE]
mov bx, 0x1000 + (15 * 512) ; Dest: 0x2E00
int 0x13
jc disk_error

; Read Kernel - Chunk 3
mov ah, 0x0e
mov al, '3'
int 0x10

mov ah, 0x02
mov al, 17          ; 15+18+17 = 50 sectors total
mov ch, 1           ; Cylinder 1
mov dh, 0           ; Head 0
mov cl, 1           ; Sector 1
mov dl, [BOOT_DRIVE]
mov bx, 0x1000 + (33 * 512) ; Dest: 0x5200
int 0x13
jc disk_error

mov bx, DoneMsg
call print_string

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
DoneMsg:
    db ' Done. Jumping to Stage 2...', 13, 10, 0

times 510-($-$$) db 0         ; Pad remaining bytes with zeros up to 510 bytes
dw 0xAA55                     ; Boot signature required by BIOS
