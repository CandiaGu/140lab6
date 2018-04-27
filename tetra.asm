        .ORG $0
      
        LDI     R0, $0  ;initialize the stack
        LDSP    R0
        BRA     START   ;jumps to main routine
        
        .ORG    $100   
START   LDI R0, $5      ;5th tetrahedral number,our arg
        PUSH R0
        JSR TETRA
        POP R0
DONE    STOP

TETRA   PUSH R0
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

        .org  $0600
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
