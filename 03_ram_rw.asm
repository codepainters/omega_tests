; 
; This test
; - sets up slots/subslots/mapper the same way C-BIOS does at startup.
; - continuously writes and reads back  a single RAM location. 
;
; The idea was to debug (with a scope), why C-BIOS fails to detect 
; the RAM.

; PPI regs - C-BIOS naming
PSL_STAT    equ     0xA8             ; slot status
KBD_STAT    equ     0xA9             ; keyboard status
GIO_REGS    equ     0xAA             ; General IO Register
PPI_REGS    equ     0xAB             ; PPI register

MAP_REG1    equ     0xFC             ; memory mapper: bank in $0000-$3FFF
MAP_REG2    equ     0xFD             ; memory mapper: bank in $4000-$7FFF
MAP_REG3    equ     0xFE             ; memory mapper: bank in $8000-$BFFF
MAP_REG4    equ     0xFF             ; memory mapper: bank in $C000-$FFFF


SSL_REGS    equ     0xFFFF

.org    0x0000

    ; configure 8255 
    ; PA - output, PB - input, PC - output
    LD      A, 0x82
    OUT     (PPI_REGS), A
    LD      A, 0x50
    OUT     (GIO_REGS), A

    ; Note: these registers are implemented as [A15:A14] addressed,
    ; using 4 74HCT670 chips (2 for readback).
    ; outputs from these constitute bits A[21:14] of the RAM address.
    ; A[21:19] should always be zero for RAM0_CS to be active.
    XOR     A
    OUT     (MAP_REG4), A        ; FF    <- 0
    INC     A
    OUT     (MAP_REG3), A        ; FE    <- 1
    INC     A
    OUT     (MAP_REG2), A        ; FD    <- 2
    INC     A
    OUT     (MAP_REG1), A        ; FC    <- 3

    ; Mimic C-BIOS here - which starts with 0xFx as slot reg value
    ; This should be enough to detect RAM in slot 3.
    IN      A,(PSL_STAT)
    OR      0xF0
    OUT     (PSL_STAT),A

    ; C-BIOS starts with sub-slot 0xF0, but it should eventually 
    ; find RAM with subslot 2 for page 3 -> hence 0xB0 (10110000 binary)
    LD      A, (SSL_REGS)
    CPL                     ; SSL reads negated
    AND     0x0F
    OR      0xB0
    LD      (SSL_REGS), A    

loop:
    ; and here is the original RAM presence test
    LD      HL, 0xFF00

    ; XXX *HL = 0x0F, if *HL != 0x0F -> chkram_find_end
    LD      A, $0F
    LD      (HL), A
    CP      (HL)
    JR      NZ, fail

    ; XXX *HL = 0xF0, if *HL != 0xF0 -> chkram_find_end
    CPL
    LD      (HL), A
    CP      (HL)
    JR      NZ, fail

    ; all OK - pulse PC0
    LD      A, 0x51
    JR      pulse

fail:
    ; failure - pulse PC0 and PC1
    LD      A, 0x53

pulse:
    OUT     (GIO_REGS), A
    LD      A, 0x50
    OUT     (GIO_REGS), A
    JP      loop
    
