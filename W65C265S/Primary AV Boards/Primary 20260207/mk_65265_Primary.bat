del *.bin
del *.obj
del *.lst

WDC816AS -DUSING_816 -L -S 65265_Primary.asm
WDCLN -HB -O 65265_Primary_raw.bin 65265_Primary.obj