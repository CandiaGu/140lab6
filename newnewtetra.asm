RTNW    .EQU    $3140
JSRW    .EQU    $3100

        .ORG $0
      
        LDI     R0, $0  ;initialize the stack
        LDSP    R0
        BRA     START   ;jumps to main routine
        
        .ORG    $100   
START   LDI R4, $4      ;5th tetrahedral number,our arg
        .DW  JSRW
        .DW  TETRA
DONE    STOP

TETRA   LDI R1, $0      ; temp return value
        CMI R0, $0      ; n
        BRZ ZERO1
        MOV R4, R0      ; parameter for tri
        .DW JSRW
        .DW TRI         ; tetrahedron subroutine
        ADD R1,R7       ; adds ret val from tri to R6
        DECR R0
        MOV R4, R0
        .DW JSRW 
        .DW TETRA       ;recursive call
	ADD R1, R7      ;adds ret val from tetra to R6
	MOV R3, R1        
	BRA DONE2
ZERO1   LDI R3, $0 
DONE2   .DW  RTNW

        .ORG  $0600
TRI     CMI   R0, $0      ; check if n == 0
        BRZ   ZERO2
NEXT    DECR  R0          ; if n > 0, calculate n - 1
        MOV   R4, R0
        .DW   JSRW
        .DW   TRI         ; then call TriRn(n-1)
        INCR  R0          ; calculate n
        ADD   R7, R0      ; add n to TriRn(n-1)
        MOV   R3, R7
        BRA   DONE3
ZERO2   LDI   R3, $0      ; if n == 0, TriRn(0) = 0
DONE3   .DW   RTNW                
