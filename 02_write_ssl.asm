; 
; This test continuously writes and reads back 
; sub-slot register at 0xFFFF address of slot 3.
;


PPI_PA      equ     0xA8
PPI_PB      equ     0xA9
PPI_PC      equ     0xAA
PPI_CTRL    equ     0xAB
SSL_REG     equ     0xFFFF

.org    0x0000

    ; configure 8255 
    ; PA - output, PB - input, PC - output
    LD      A, 0x82
    OUT     (PPI_CTRL), A

    ; Setup slots - as we need the right slot at 0xFFFF.
    ; Let's set last page to slot 3, other pages to slot 0.
    LD      A, 0xC0
    OUT     (PPI_PA), A

    ; start with 0x01
    LD      HL, SSL_REG
    LD      A, 0x01

loop:
    ; on each iteration, set SSL to A, read it back to C
    LD      (HL), A
    LD      C, (HL)
    ; then rotate A left, loop endlessly
    RLCA
    JP      loop
