[org 0x7E00]

jmp Main

Main:
    mov bx, SecondStageMsg
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

SecondStageMsg:
    db 'Second stage loaded!', 0
