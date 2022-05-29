ENTRY(start)

SECTIONS 
{
    . = 1M; /*current address AKA all our OS data will start 1Megabyte in -> convention pour boot loader*/

    .boot :
    {
        KEEP(*(.multiboot_header))
    }

    .text :
    {
        *(.text)
    }
} 