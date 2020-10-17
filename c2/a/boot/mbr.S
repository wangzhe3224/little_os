; Main Boot Record, MBR
; ---------- 
SECTION MBR vstart=0x7c00
; BIOS jump to MBR via jmp 0: 0x7c00, hence current cs is 0.
; CPU cannot do immediate assignment to regiester, so we move value from cs to other
; regirsters to initialize them.
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00     ; stack point. 0x7c00 is currently save to be used.
; 0x06 clean screen, here will remove all BIOS output from screen.
    mov ax, 0x600
    mov bx, 0x700
    mov cx, 0          ; left conner: (0, 0)
    mov dx, 0x184f     ; right conner: (80, 25)
    int 0x10           ; BIOS interrupt. Read parameter from ax
; get cursor location
    mov ah, 3          ; sub routine 3: get cursor location
    mov bh, 0          ; page number of the cursor
    int 0x10           ; output: ch=start, cl=end
                       ; dh=row of cursor, dl=col of cursor
; print
    mov ax, message
    mov bp, ax         ; es:bp is first address, now es is as same as cs

    mov cx, 5          ; length of the print string
    mov ax, 0x1301     ; sub routine 13: show chars and property
    mov bx, 0x2        ; bh stores page number, bl stores char property, 0x02, green char
    int 0x10           ; BIOS 0x01 interupt
; finish print char
    
    jmp $              ; suspend here

    message db "1 MBR"
    times 510-($-$$) db 0  ; $$ is the start address of this section, 
                           ; $ is the address of current this line.
                           ; so $ - $$ is the offset 
                           ; this is just to fill the memory till end sign of MBR
    db 0x55, 0xaa      ; these are magic number indicating that MBR ended.
