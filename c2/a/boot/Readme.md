run `nasm -o mbr.bin mbr.S` to compile our dummy MBR. Then we need to build an image for `qemu` to simulate with. 

`dd if=/your_path/mbr.bin of=/your_path/bochs/hd60M.img bs=512 count=1 conv=notrunc`

After we got the image with our MBR. Start simulate of the booting:

`qemu-system-i386 -curses hd60M.img`
