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

TETF    LDI R1, $0      ; temp return value
        CMI R0, $0      ; n
        BRZ ZERO1
        MOV R4, R0      ; parameter for tri
        BRW TRIC        ;if w set go slow
TRIFC   .DW JSRW
        .DW TRI         ; tetrahedron subroutine
TRIC    PUSH..;old stack discipline
        JSR TRI
        POP ..;old stack discipline
        ADD R1,R7       ; adds ret val from tri to R6
        DECR R0
        MOV R4, R0
        BRW TETC       ;if w set go slow
TETFC   .DW JSRW       ;fast tet
        .DW TETW       ;recursive call
        PUSH..;old discipline
TETC    JSR TET
        POP..;old discipline
	ADD R1, R7      ;adds ret val from tetra to R6
	MOV R3, R1        
	BRA DONE2
ZERO1   LDI R3, $0 
DONE2   .DW  RTNW

        .ORG  $0600
TRIW    CMI   R0, $0      ; check if n == 0
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

TET     PUSH R0
        PUSH R6
        LDSF R0,$3      ;parameter n
        LDI R6, $0
        CMI R0, $0      
        BRZ ZERO1
        PUSH R0
        JSR TRI         ;tetrahedron subroutine
        POP R0
        ADD R6,R7       ;adds ret val from tri to R6
        DECR R0
        PUSH R0
        JSR TETRA       ;recursive call
        POP R0
	ADD R6, R7      ;adds ret val from tetra to R6
	MOV R7, R6        
	BRA DONE2
ZERO1   LDI R7, $0 
DONE2   POP R6
        POP R0
        RTN

        .ORG  $0600
TRI     PUSH  R1          ; save register R1
        LDSF  R1, $2      ; read n from stack
        CMI   R1, $0      ; check if n == 0
        BRZ   ZERO2
NEXT    DECR  R1          ; if n > 0, calculate n - 1
        PUSH  R1
        JSR   TRI         ; then call TriRn(n-1)
        POP   R1
        INCR  R1          ; calculate n
        ADD   R7, R1      ; add n to TriRn(n-1)
        BRA   DONE3
ZERO2   LDI   R7, $0      ; if n == 0, TriRn(0) = 0
DONE3   POP   R1          ; restore register R1
        RTN                
