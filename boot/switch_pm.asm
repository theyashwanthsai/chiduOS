[bits 16]
switch_to_pm:
    ; Print debug message before switching
    mov si, debug_msg
    call print_string
    
    cli                ; Disable interrupts
    lgdt [gdt_desc]        ; Load GDT
    mov eax, cr0           ; Get control register 0
    or al, 1               ; Set PE bit
    mov cr0, eax           ; Write back to control register
    
    ; Far jump to flush pipeline and switch to 32-bit mode
    jmp 0x08:BEGIN_PM

[bits 32]
BEGIN_PM:
    ; Set up segment registers for 32-bit mode
    mov ax, 0x10           ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Set up stack
    mov esp, 0x90000
    
    ; Print protected mode message using print_string_pm
    mov esi, pm_msg
    mov edi, 0xb8000 + (80 * 21 * 2)  ; Last line
    call print_string_pm

.hang:
    ; Try to jump to kernel
    cmp dword [0x1000], 0x7F454C46  ; Correct little-endian ELF magic
    je .no_kernel
    
    mov esi, jump_msg
    mov edi, 0xb8000 + (80 * 22 * 2)  ; Last line
    call print_string_pm
    
    jmp 0x1000            ; Jump to kernel
    
.no_kernel:
    ; Print error message using print_string_pm
    mov esi, no_kernel_msg
    mov edi, 0xb8000 + (80 * 21 * 2)  ; Last line
    call print_string_pm
    
.hang_here:
    mov esi, hang_msg
    mov edi, 0xb8000 + (80 * 22 * 2)  ; Last line
    call print_string_pm
    jmp $

debug_msg db 'About to switch to PM...', 13, 10, 0
pm_msg db 'Switched to Protected Mode OK', 0
no_kernel_msg db 'No kernel found at 0x1000!', 0
jump_msg db 'Jumping to kernel!', 0
hang_msg db 'Hanging to infinity', 0
