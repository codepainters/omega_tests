; 
; Simple test toggling PA[7..0] outputs endlessly, avoiding RAM access.
;


PPI_PA      equ     0xA8
PPI_PB      equ     0xA9
PPI_PC      equ     0xAA
PPI_CTRL    equ     0xAB


.org    0x0000

    ; configure 8255 
    ; PA - output, PB - input, PC - output
    LD      A, 0x82
    OUT     (PPI_CTRL), A

loop:
    LD      A, 0xAA
    OUT     (PPI_PC), A
    LD      A, 0x55
    OUT     (PPI_PC), A
    JP      loop
