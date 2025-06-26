[bits 16]
align 4
gdt_start:
    ; Null descriptor
    dq 0x0000000000000000
    
    ; Code segment descriptor (0x08)
    dw 0xFFFF    ; Limit 0-15
    dw 0x0000    ; Base 0-15  
    db 0x00      ; Base 16-23
    db 10011010b ; Access byte (present, ring 0, code, readable)
    db 11001111b ; Flags + Limit 16-19
    db 0x00      ; Base 24-31
    
    ; Data segment descriptor (0x10)
    dw 0xFFFF    ; Limit 0-15
    dw 0x0000    ; Base 0-15
    db 0x00      ; Base 16-23
    db 10010010b ; Access byte (present, ring 0, data, writable)
    db 11001111b ; Flags + Limit 16-19
    db 0x00      ; Base 24-31
gdt_end:

gdt_desc:
    dw gdt_end - gdt_start - 1
    dd gdt_start