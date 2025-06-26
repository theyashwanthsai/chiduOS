[bits 16]
load_kernel:
    mov ah, 0x02          ; BIOS read sectors function
    mov al, 15            ; Number of sectors to read
    mov ch, 0             ; Cylinder 0
    mov cl, 2             ; Sector 2 (sector 1 is bootloader)
    mov dh, 0             ; Head 0
    mov dl, [boot_drive]  ; Drive number
    mov bx, 0x1000        ; Load to address 0x1000
    int 0x13              ; BIOS interrupt for disk operations
    jc .error             ; Jump if error (carry flag set)
    
    ; If we get here, the read was successful
    mov si, kernel_load_msg
    call print_string
    ret
    
.error:
    mov si, err_msg
    call print_string
    jmp $

err_msg db 'Disk error', 13, 10, 0
kernel_load_msg db 'Kernel is being loaded!', 13, 10, 0