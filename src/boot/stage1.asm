[org 0x7C00]
KERNEL_OFFSET equ 0x1000

    jmp 0:start

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000

    mov [BOOT_DRIVE], dl

    mov bx, MSG_REAL_MODE
    call print_string

    call load_kernel

    mov bx, MSG_DONE
    call print_string

    jmp 0x7E00          ; Jump to Stage 2

; Code inlined below.


[bits 16]
load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print_string

    ; Load Stage 2 (1 sector at LBA 1) -> 0x7E00
    mov bx, 0x7E00
    mov dh, 0           ; Head 0
    mov dl, [BOOT_DRIVE]
    mov cl, 2           ; Start from sector 2 (LBA 1)
    mov ch, 0
    mov ah, 0x02
    mov al, 1
    int 0x13
    jc stage2_error

    ; Load Kernel (50 sectors at LBA 2 -> Sector 3) -> KERNEL_OFFSET
    mov bx, KERNEL_OFFSET
    mov dh, 50          ; Read 50 sectors
    mov dl, [BOOT_DRIVE]
    call disk_load_lba  ; Call inline function
    
    ret

BOOT_DRIVE db 0
MSG_REAL_MODE db "Started in 16-bit Real Mode", 13, 10, 0
MSG_LOAD_KERNEL db "Loading Kernel...", 13, 10, 0
MSG_DONE db "Done. Jumping to Stage 2...", 13, 10, 0
MSG_DISK_ERROR db "Disk read error!", 0
MSG_STAGE2_ERROR db "Disk Error (Stage2)!", 0

; LBA Read Buffer
; Input: BX = Destination, DH = Sector Count
; Reads from LBA 2 (Sector 3) hardcoded start for Kernel
disk_load_lba:
    push dx
    push si
    push di
    push bp
    
    ; Start at LBA 2 => Sector 3, Head 0, Cylinder 0
    mov si, 3           ; Sector
    mov di, 0           ; Head
    mov bp, 0           ; Cylinder

.loop:
    push dx
    
    ; Setup registers for int 0x13
    ; We need to move values from SI(Sector), DI(Head), BP(Cylinder) 
    ; to CL, DH, CH respectively.
    ; Since we can't move 16-bit regs to 8-bit regs directly, use AX.
    
    mov ax, bp      ; Cylinder
    mov ch, al
    
    mov ax, si      ; Sector
    mov cl, al
    
    mov ax, di      ; Head
    mov dh, al
    
    mov dl, [BOOT_DRIVE]
    mov ah, 0x02
    mov al, 1
    int 0x13
    jc disk_error

    pop dx
    add bx, 512         ; Next buffer position
    
    ; Next CHS
    inc si
    cmp si, 18          ; Max Sector 18
    jna .next           ; If <= 18, OK
    
    mov si, 1           ; Reset Sector to 1
    inc di              ; Next Head
    cmp di, 1           ; Max Head 1 (indices 0, 1)
    jna .next           ; If <= 1, OK
    
    mov di, 0           ; Reset Head to 0
    inc bp              ; Next Cylinder
    
.next:
    dec dh
    cmp dh, 0
    jne .loop

    pop bp
    pop di
    pop si
    pop dx
    ret

disk_error:
    mov bx, MSG_DISK_ERROR
    call print_string
    jmp $

stage2_error: ; Added
    mov bx, MSG_STAGE2_ERROR
    call print_string
    jmp $

print_string:
    mov ah, 0x0E
.loop:
    mov al, [bx]
    cmp al, 0
    je .done
    int 0x10
    inc bx
    jmp .loop
.done:
    ret

times 510-($-$$) db 0
dw 0xaa55

