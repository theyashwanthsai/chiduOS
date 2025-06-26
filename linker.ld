ENTRY(kernel_entry)

SECTIONS
{
    . = 0x1000;  /* Kernel loads at 0x1000 */
    
    .text : {
        *(.text.entry)
        *(.text)
    }
    
    .rodata : {
        *(.rodata)
    }
    
    .data : {
        *(.data)
    }
    
    .bss : {
        *(.bss)
        *(COMMON)
    }
    
    /* End of kernel marker */
    kernel_end = .;
}