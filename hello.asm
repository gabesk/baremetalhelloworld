org 0x7C00          ; The BIOS loads the bootloader at 0x7C00 so tell NASM
                    ; to add that amount to to label addresses.

bits 16             ; Tell NASM to use 16 bit encoding.

mov ax, 0x2401      ; Disable A20 line. (There are theoretically various
int 0x15            ; ways one should try but in this simple example assume
                    ; the BIOS is modern enough to support this interrupt.)

cli                 ; Disable interrupts; they will remain disabled for the
                    ; duration of this example so that we don't have to set
                    ; up an IDT.

mov ax, GDT         ; Get a pointer to GDT and store it in gdtr.
mov [gdtr + 2], ax
LGDT [gdtr]

mov al, 0x64        ; Store the TSS at 0x500. Zero that memory in case.
mov bx, 0x500       ; (Since interrupts are never enabled, this isn't really
zero_tss:           ;  needed.)
mov [bx], byte 0
inc bx
dec al
jg zero_tss

mov eax, cr0        ; Enable protected mode.
or eax, 1
mov cr0,eax

                    ; Reload CS register containing code selector
jmp 0x08:reload_cs  ; 0x08 points at the new code selector.

bits 32             ; At this point, the processor is operating in 32 bit mode
                    ; and instructions should be assembled as such.

reload_cs:          ; Reload data segment registers.
mov ax, 0x10        ; 0x10 points at the new data selector.
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax

mov eax, 0x1000     ; Zero the memory at 0x1000 - 0x3000 for pagetables.
zero_mem:
mov [eax], byte 0
inc ax
cmp ax, 0x3000
jb zero_mem

mov eax, 0x1000     ; The first PDE in the page directory needs to be valid and
                    ; point to a page table to identity map the first 1mb.
                        
mov [eax], word 0x2001  ; The first entry in the page directory is present and
                        ; points to 0x2000.


; Create a simple page table which identity maps < 1 mb.
; Each page maps 4 kB and there are 1024 page table entries, so that is 4
; megabytes mapped. So the first page table will be 1/4th mapped. And the page
; directory entries each map 4 MB and there are 1024 of them providing 4 GB.
; How would you say that, say, 0x1000 virtual address maps to 0x1000 physical
; address?
; You'd put the 1st (not 0th) pte in the 0th page table to PFN 1, and so on.
; How about 0x2000? Then you'd put the 2nd pte to PFN 2.

mov eax, 0x2000     ; The first page table is identity mapped. Only the first
mov ebx, 1          ; megabyte is mapped, so only the first 256 entries. 
create_page_table:
mov [eax], ebx
add eax, 4
add ebx, 0x1000
cmp eax, 0x2400
jb create_page_table

mov eax, 0x1000     ; Enable paging.   
mov cr3, eax
mov eax, cr0
or eax, 0x80000000
mov cr0, eax

; If everything went well, this code is now operating in identity mapped
; protected mode!

mov eax, 0xB8000    ; Clear the screen.    
mov bx, 1920
clear_screen:
mov [eax], byte 32  ; space
inc eax
mov [eax], byte 7   ; regular white
inc eax
dec bx
jnz clear_screen

                    ; Write hello world to the screen.
mov eax, 0xB8000    ; Address of text mode video framebuffer.
mov bx, welcome     ; Address of our hello world string.
write_hello:
mov cl, [bx]
mov [eax], cl
inc eax
mov [eax], byte 0x07; The color of the character
inc eax
inc bx
cmp [bx], byte 0
jne write_hello

; mov eax, 0x100000 ; Access something outside of 1MB to ensure fault.
; mov ebx, [eax]

end:
jmp end

welcome db 'Hello world!', 0

                    ; A simple GDT for enabling protected mode
gdtr    DW 32       ; limit
        DD 0        ; base

GDT     DQ 0
GDT_CS  DD 0x0000ffff, 0xcf9a00
GDT_DS  DD 0x0000ffff, 0xcf9200
GDT_TSS DD 0x05000064, 0x408900

times 510-($-$$) db 0
dw 0AA55h