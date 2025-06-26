[org 0x7C00]
[bits 16]

; Stack setup
mov bp, 0x8000
mov sp, bp
mov [boot_drive], dl

; Print boot message
mov si, boot_msg
call print_string

; Load kernel
call load_kernel

mov si, kernel_loaded_msg
call print_string

; Switch to protected mode
call switch_to_pm

; Should never reach here
jmp $

; Include compact modules
%include "print.asm"
%include "disk.asm" 
%include "gdt.asm"
%include "switch_pm.asm"

; === DATA SECTION ===
boot_msg db 'Booting OS-2...........', 13, 10, 0
kernel_loaded_msg db 'Kernel loaded successfully', 13, 10, 0
boot_drive db 0

; Boot sector padding
times 510-($-$$) db 0
dw 0xAA55