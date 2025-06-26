; print.asm - Compact print functions

[bits 16]
print_string:
    pusha
    mov ah, 0x0e
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

[bits 32]
; Improved print_string_pm with position control
; Input: ESI = string address, EDI = screen position (optional)
print_string_pm:
    pusha
    mov ebx, 0xb8000      ; VGA buffer start
    
    ; If EDI != 0, use it as position (allows caller to specify location)
    test edi, edi
    jnz .position_set
    mov edi, ebx          ; Default to top-left if EDI=0
.position_set:
    
    mov ah, 0x0F          ; White on black attribute
.loop:
    lodsb                 ; Load next char
    test al, al
    jz .done
    mov [edi], ax         ; Store char + attribute
    add edi, 2            ; Next screen position
    jmp .loop
.done:
    popa
    ret