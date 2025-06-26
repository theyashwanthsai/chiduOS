[bits 32]
global kernel_entry
extern kernel_main

kernel_entry:
    ; Set up protected mode segments (critical!)
    mov ax, 0x10      ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Stack setup (move higher to avoid conflicts)
    mov esp, 0xA0000  ; 640KB mark
    
    call kernel_main   ; Transfer control to C
    
    ; Fallback (should never reach here)
    cli
    hlt
    jmp $