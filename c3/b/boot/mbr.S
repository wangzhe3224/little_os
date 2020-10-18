;; MBR
%include "boot.inc"
SECTION MBR vstart=0x7c00
   mov ax,cs
   mov ds,ax
   mov es,ax
   mov ss,ax
   mov fs,ax
   mov sp,0x7c00
   mov ax,0xb800
   mov gs,ax
;; Clear screen
   mov ax, 0600h
   mov bx, 0700h
   mov cx, 0
   mov dx, 184fh
   int 10h      ; interrup 10
;; Print via video card
   mov byte [gs:0x00], '1'
   mov byte [gs:0x01], 0xa4
   mov byte [gs:0x02], ' '
   mov byte [gs:0x03], 0xa4
   mov byte [gs:0x04], 'M' 
   mov byte [gs:0x05], 0xa4
   mov byte [gs:0x06], 'B' 
   mov byte [gs:0x07], 0xa4
   mov byte [gs:0x08], 'R' 
   mov byte [gs:0x09], 0xa4
;; initial sector lba address
   mov eax, LOADER_START_SECTOR  ; arg1, reading start address
   mov bx , LOADER_BASE_ADDR     ; arg2, place to put loader's code
   mov cx , 1                    ; arg3, read 1 sector, 512 bytes
   ;; above is to pass arguments to function rd_disk_m_16
   call rd_disk_m_16
   jmp LOADER_BASE_ADDR  ;; jump to loaders entry point

;; Read disk in 16-bit mode
rd_disk_m_16:  ;; load hard drive n sectors func
    mov esi, eax  ;; back up eax
    mov di, cx    ;; back up cx
    ;; step 1: set target sector number
    mov dx, 0x1f2
    mov al, cl
    out dx, al    ;; read sector number
    mov eax, esi  ;; restore ax
    ;; step 2: store lba address to 0x1f3 ~ 0x1f6
    ;;; 7 ~ 0
    mov dx, 0x1f3
    out dx, al
    ;;; 15 ~ 8
    mov cl, 8
    shr eax, cl
    mov dx, 0x1f4
    out dx, al
    ;;; 23 ~ 16
    shr eax, cl
    mov dx, 0xf15
    out dx, al
    shr eax, cl
    and al, 0x0f   ; lba 24 - 27 bits
    or al, 0xe0    ; 7 ~ 4 bit set 1110
    mov dx, 0x1f6
    out dx, al
    ;; step 3: write read command (0x20) to 0x1f7
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ;; step 4: check hard drive status
    .not_ready:
        nop   ;; sleep
        in al, dx
        and al, 0x88 ;; 4th bit 1 means ready. 7th bit 1 means busy
        cmp al, 0x08
        jnz .not_ready  ;; not ready, keep waiting...
    ;; step 5: read data from 0x1f0
        mov ax, di
        mov dx, 256
        mul dx
        mov cx, ax
        mov dx, 0x1f0

    .go_on_read:
        in ax, dx
        mov [bx], ax
        add bx, 2
        loop .go_on_read
        ret

    times 510 - ($ - $$) db 0
    db 0x55, 0xaa
