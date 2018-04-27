/*
 * File: controlpath.v
 * Created: 4/5/1998
 * Modules contained: controlpath
 *
 * The condition codes are ordered as ZCNV
 * 
 * Changelog:
 * 9 June 1999 : Added stack pointer 
 * 4/16/2001: Reverted to base code (verBurg)
 * 4/16/2001: Added the "addsp" instruction. (verBurg)
 * 11/26/06: Removed old Altera-specific code that Xilinx tool had trouble with (P. Milder)
 * 07 Oct 2009: Cleaned up coding style somewhat and made minor changes (mcb   winAddSub = 2'b0;
        ender)
 * 08 Oct 2009: Fixed minor errors (mcb   winAddSub = 2'b0;
        ender)
 * 12 Oct 2009: Minor naming changes for consistency with modules.v (mcb   winAddSub = 2'b0;
        ender)
 * 13 Oct 2009: Removed tabs and fixed spacing (mcb   winAddSub = 2'b0;
        ender)
 * 18 Oct 2009: Changed some constant names (mcb   winAddSub = 2'b0;
        ender)
 * 23 Oct 2009: Renamed from paths.v to controlpath.v, moved datapath to datapath.v
 * 13 Oct 2010: Updated always to always_comb and always_ff. Removed #1 before finish,
 *              as timing controls not allowed in always_comb. Renamed to .sv. (abeera)    
 * 17 Oct 2010: Updated to use enums instead of define's (iclanton)
 * 24 Oct 2010: Updated to use struct (abeera)
 * 9  Nov 2010: Slightly modified variable names (abeera)
 * 13 Nov 2010: Modified to use static instead of dynamic casting (abeera)
 * 23 Apr 2012: Modified to have two stop states, the first decrements PC, per ISA (leifan)
 */

`include "constants.sv"

/*
 * module controlpath
 *
 * This is the FSM for the p18240.  Any modifications to the ISA 
 * or even the base implementation will most likely affect this module.
 * (Hint, hint.)
 */
module controlpath (
   input [3:0]       CCin,
   input [15:0]      IRIn,
   output controlPts out,
   output opcode_t currState,
   output opcode_t nextState,
   output [1:0]      winAddSub,
   input             clock,
   input             reset_L);
  
   always_ff @(posedge clock or negedge reset_L)
     if (~reset_L)
       currState <= FETCH;
     else
       currState <= nextState;

   // order of control points: 
   // {ALU fn, AmuxSel, BmuxSel, DestDecode, CCLoad, RE, WE}

   always_comb begin
      case (currState)
        FETCH: begin
           out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH1;
            winAddSub = 2'b0;
        end
        FETCH1: begin
           out = {F_A_PLUS_1, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR};
           nextState = FETCH2;
            winAddSub = 2'b0;
        end
        FETCH2: begin
           out = {F_A, MUX_MDR, 2'bxx, DEST_IR, NO_LOAD, NO_RD, NO_WR};
           nextState = DECODE;
           winAddSub = 2'b0;
        end
        DECODE: begin
           out = {4'bxxxx, 2'bxx, 2'bxx, DEST_NONE, NO_LOAD, NO_RD, NO_WR};
           nextState = opcode_t'(IRIn[15:6]);
         //  $cast(nextState, IRIn[15:6]);
           winAddSub = 2'b0;
        end
        LDI: begin
           out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = LDI1;
           winAddSub = 2'b0;
        end
        LDI1: begin
           out = {F_A_PLUS_1, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR};
           nextState = LDI2;
           winAddSub = 2'b0;
        end
        LDI2: begin
           out = {F_A, MUX_MDR, 2'bxx, DEST_REG, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        ADD: begin
           out = {F_A_PLUS_B, MUX_REG, MUX_REG, DEST_REG, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        SUB: begin
           out = {F_A_MINUS_B, MUX_REG, MUX_REG, DEST_REG, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        INCR: begin
           out = {F_A_PLUS_1, MUX_REG, 2'bxx, DEST_REG, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        DECR: begin
           out = {F_A_MINUS_1, MUX_REG, 2'bxx, DEST_REG, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        LDR: begin
         out = {F_B, 2'bxx, MUX_REG, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = LDR1;
           winAddSub = 2'b0;
        end
        LDR1: begin
           out = {4'bxxxx, 2'bxx,2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR};
           nextState = LDR2;
           winAddSub = 2'b0;
        end
        LDR2: begin
           out = {F_A, MUX_MDR,2'bxx, DEST_REG, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        BRA: begin
           out = {F_A, MUX_PC,2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = BRA1;
           winAddSub = 2'b0;
        end
        BRA1: begin
           out = {4'bxxxx, 2'bxx,2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR};
           nextState = BRA2;
           winAddSub = 2'b0;
        end
        BRA2: begin
           out = {F_A, MUX_MDR,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        BRN: begin
           out = {F_A, MUX_PC,2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           if (CCin[1]) 
             nextState = BRN2;
           else 
             nextState = BRN1;
           winAddSub = 2'b0;
        end
        BRN1: begin
           out = {F_A_PLUS_1, MUX_PC,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        BRN2: begin
           out = {4'bxxxx, 2'bxx,2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR};
           nextState = BRN3;
           winAddSub = 2'b0;
        end
        BRN3: begin
           out = {F_A, MUX_MDR,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        BRZ: begin
           out = {F_A, MUX_PC,2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           if (CCin[3]) 
             nextState = BRZ2;
           else 
             nextState = BRZ1;
           winAddSub = 2'b0;
        end
        BRZ1: begin
           out = {F_A_PLUS_1, MUX_PC,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        BRZ2: begin
           out = {4'bxxxx, 2'bxx,2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR};
           nextState = BRZ3;
           winAddSub = 2'b0;
        end
        BRZ3: begin
           out = {F_A, MUX_MDR,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end       
        STOP: begin
           out = {F_A_MINUS_1, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR};
           nextState = STOP1;
           winAddSub = 2'b0;
        end
        STOP1: begin
           out = {8'bxx, DEST_NONE, NO_LOAD, NO_RD, NO_WR}; // same as above
           nextState = STOP1; // This is to avoid a latch
`ifndef synthesis
           $display("STOP occurred at time %d", $time);
            $finish;
`   winAddSub = 2'b0;
        endif
           winAddSub = 2'b0;
        end
        BRC: begin
           out = {F_A, MUX_PC,2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           if (CCin[2]) 
             nextState = BRC2;
           else 
             nextState = BRC1;
           winAddSub = 2'b0;
        end
        BRC1: begin
           out = {F_A_PLUS_1, MUX_PC,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        BRC2: begin
           out = {4'bxxxx, 2'bxx,2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR};
           nextState = BRC3;
           winAddSub = 2'b0;
        end
        BRC3: begin
           out = {F_A, MUX_MDR,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        BRV: begin
           out = {F_A, MUX_PC,2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           if (CCin[0]) 
             nextState = BRV2;
           else 
             nextState = BRV1;
           winAddSub = 2'b0;
        end
        BRV1: begin
           out = {F_A_PLUS_1, MUX_PC,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        BRV2: begin
           out = {4'bxxxx, 2'bxx,2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR};
           nextState = BRV3;
           winAddSub = 2'b0;
        end
        BRV3: begin
           out = {F_A, MUX_MDR,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end 
        // logical functions:
        AND: begin
           out = {F_A_AND_B, MUX_REG, MUX_REG, DEST_REG, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        NOT: begin
           out = {F_A_NOT, MUX_REG,2'bxx, DEST_REG, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        OR: begin
           out = {F_A_OR_B, MUX_REG, MUX_REG, DEST_REG, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        XOR: begin
           out = {F_A_XOR_B, MUX_REG, MUX_REG, DEST_REG, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        // illogical func--er, Comparison functions:
        CMI: begin
           out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = CMI1;
           winAddSub = 2'b0;
        end
        CMI1: begin
           out = {F_A_PLUS_1, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR};
           nextState = CMI2;
           winAddSub = 2'b0;
        end
        CMI2: begin
           out = {F_A_MINUS_B, MUX_REG, MUX_MDR, DEST_NONE, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        CMR: begin
           out = {F_A_MINUS_B, MUX_REG, MUX_REG, DEST_NONE, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        // Shift functions:
        ASHR: begin
           out = {F_A_ASHR, MUX_REG,2'bxx, DEST_REG, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        LSHL: begin
           out = {F_A_SHL, MUX_REG,2'bxx, DEST_REG, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        LSHR: begin
           out = {F_A_LSHR, MUX_REG,2'bxx, DEST_REG, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        ROL: begin
           out = {F_A_ROL, MUX_REG,2'bxx, DEST_REG, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        // Data movement functions:
        MOV: begin
           out = {F_B, 2'bxx, MUX_REG, DEST_REG, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        LDA: begin
           out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = LDA1;
           winAddSub = 2'b0;
        end
        LDA1: begin
           out = {F_A_PLUS_1, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR};
           nextState = LDA2;
           winAddSub = 2'b0;
        end
        LDA2: begin
           out = {F_A, MUX_MDR, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = LDA3;
           winAddSub = 2'b0;
        end
        LDA3: begin
           out = {4'bxxxx, 2'bxx, 2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR};
           nextState = LDA4;
           winAddSub = 2'b0;
        end
        LDA4: begin
           out = {F_A, MUX_MDR, 2'bxx, DEST_REG, LOAD_CC, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        STA: begin
           out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = STA1;
           winAddSub = 2'b0;
        end
        STA1: begin
           out = {F_A_PLUS_1, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR};
           nextState = STA2;
           winAddSub = 2'b0;
        end
        STA2: begin
           out = {F_A, MUX_MDR, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = STA3;
           winAddSub = 2'b0;
        end
        STA3: begin
           out = {F_B, 2'bxx, MUX_REG, DEST_MDR, NO_LOAD, NO_RD, NO_WR};
           nextState = STA4;
           winAddSub = 2'b0;
        end
        STA4: begin
           out = {4'bxxxx, 2'bxx, 2'bxx, DEST_NONE, NO_LOAD, NO_RD, MEM_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        STR: begin
           out = {F_A, MUX_REG,2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = STR1;
           winAddSub = 2'b0;
        end
        STR1: begin
           out = {F_B, 2'bxx, MUX_REG, DEST_MDR, NO_LOAD, NO_RD, NO_WR};
           nextState = STR2;
           winAddSub = 2'b0;
        end
        STR2: begin
           out = {4'bxxxx, 2'bxx,2'bxx, DEST_NONE, NO_LOAD, NO_LOAD, NO_RD, MEM_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        // Stack based ops:
        JSR: begin
           out = {F_A_MINUS_1, MUX_SP,2'bxx, DEST_SP, NO_LOAD, NO_RD, NO_WR};
           nextState = JSR1;
           winAddSub = 2'b0;
        end
        JSR1: begin
           out = {F_A, MUX_SP,2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = JSR2;
           winAddSub = 2'b0;
        end
        JSR2: begin
           out = {F_A_PLUS_1, MUX_PC,2'bxx, DEST_MDR, NO_LOAD, NO_RD, NO_WR};
           nextState = JSR3;
           winAddSub = 2'b0;
        end
        JSR3: begin
           out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, MEM_WR};
           nextState = JSR4;
           winAddSub = 2'b0;
        end
        JSR4: begin
           out = {4'bxxxx, 2'bxx,2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR};
           nextState = JSR5;
           winAddSub = 2'b0;
        end
        JSR5: begin
           out = {F_A, MUX_MDR,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        JSRW: begin
           out = {F_A_MINUS_1, MUX_SP,2'bxx, DEST_SP, NO_LOAD, NO_RD, NO_WR};
           nextState = JSR1;
           winAddSub = 2'b10;
        end
/*
        JSRW1: begin
           out = {F_A, MUX_SP,2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = JSRW2;
           winAddSub = 2'b0;
        end
        JSRW2: begin
           out = {F_A_PLUS_1, MUX_PC,2'bxx, DEST_MDR, NO_LOAD, NO_RD, NO_WR};
           nextState = JSRW3;
           winAddSub = 2'b0;
        end
        JSRW3: begin
           out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, MEM_WR};
           nextState = JSRW4;
           winAddSub = 2'b0;
        end
        JSRW4: begin
           out = {4'bxxxx, 2'bxx,2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR};
           nextState = JSRW5;
           winAddSub = 2'b0;
        end
        JSRW5: begin
           out = {F_A, MUX_MDR,2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
*/
        end
        RTNW: begin
           out = {F_A, MUX_SP, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = RTN1;
           winAddSub = 2'b1;
        end
/*
        RTNW1: begin
           out = {F_A_PLUS_1, MUX_SP, 2'bxx, DEST_SP, NO_LOAD, MEM_RD, NO_WR};
           nextState = RTNW2;
           winAddSub = 2'b0;
        end
        RTNW2: begin
           out = {F_A, MUX_MDR, 2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
*/
        end
        LDSF: begin
           out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = LDSF1;
           winAddSub = 2'b0;
        end
        LDSF1: begin
           out = {F_A_PLUS_1, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR};
           nextState = LDSF2;
           winAddSub = 2'b0;
        end
        LDSF2: begin
           out = {F_A_PLUS_B, MUX_MDR, MUX_SP, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = LDSF3;
           winAddSub = 2'b0;
        end
        LDSF3: begin
           out = {4'bxxxx, 2'bxx,2'bxx, DEST_NONE, NO_LOAD, MEM_RD, NO_WR};
           nextState = LDSF4;
           winAddSub = 2'b0;
        end
        LDSF4: begin
           out = {F_A, MUX_MDR, 2'bxx, DEST_REG, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        LDSP: begin
           out = {F_A, MUX_REG, 2'bxx, DEST_SP, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        POP: begin
           out = {F_A, MUX_SP, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = POP1;
           winAddSub = 2'b0;
        end
        POP1: begin
           out = {F_A_PLUS_1, MUX_SP, 2'bxx, DEST_SP, NO_LOAD, MEM_RD, NO_WR};
           nextState = POP2;
           winAddSub = 2'b0;        
	end
        POP2: begin
           out = {F_A, MUX_MDR, 2'bxx, DEST_REG, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;        
        end
        PUSH: begin
           out = {F_A_MINUS_1, MUX_SP, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = PUSH1;
           winAddSub = 2'b0;        
	end
        PUSH1: begin
           out = {F_A, MUX_REG, 2'bxx, DEST_MDR, NO_LOAD, NO_RD, NO_WR};
           nextState = PUSH2;
           winAddSub = 2'b0;
        end
        PUSH2: begin
           out = {F_A_MINUS_1, MUX_SP, 2'bxx, DEST_SP, NO_LOAD, NO_RD, MEM_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        RTN: begin
           out = {F_A, MUX_SP, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = RTN1;
           winAddSub = 2'b0;
        end
        RTN1: begin
           out = {F_A_PLUS_1, MUX_SP, 2'bxx, DEST_SP, NO_LOAD, MEM_RD, NO_WR};
           nextState = RTN2;
           winAddSub = 2'b0;
        end
        RTN2: begin
           out = {F_A, MUX_MDR, 2'bxx, DEST_PC, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        STSF: begin
           out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = STSF1;
           winAddSub = 2'b0;
        end
        STSF1: begin
           out = {F_A_PLUS_1, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR};
           nextState = STSF2;
           winAddSub = 2'b0;
        end
        STSF2: begin
           out = {F_A_PLUS_B, MUX_MDR, MUX_SP, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = STSF3;
           winAddSub = 2'b0;
        end
        STSF3: begin
           out = {F_A, MUX_REG, 2'bxx, DEST_MDR, NO_LOAD, NO_RD, NO_WR};
           nextState = STSF4;
           winAddSub = 2'b0;
        end
        STSF4: begin
           out = {4'bxxxx, 2'bxx, 2'bxx, DEST_NONE, NO_LOAD, NO_LOAD, NO_RD, MEM_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        ADDSP: begin
           // get IMM value by putting PC on MAR:
           out = {F_A, MUX_PC, 2'bxx, DEST_MAR, NO_LOAD, NO_RD, NO_WR};
           nextState = ADDSP1;
           winAddSub = 2'b0;
        end
        ADDSP1: begin
           // add one to PC and store back, read memory from PC:
           out = {F_A_PLUS_1, MUX_PC, 2'bxx, DEST_PC, NO_LOAD, MEM_RD, NO_WR};
           nextState = ADDSP2;
           winAddSub = 2'b0;
        end
        ADDSP2: begin
           // add MDR with SP and store into SP:
           out = {F_A_PLUS_B, MUX_MDR, MUX_SP, DEST_SP, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        STSP: begin
           out = {F_A, MUX_SP, 2'bxx, DEST_REG, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        NEG: begin
           out = {F_A_NOT, MUX_REG, 2'bxx, DEST_REG, NO_LOAD, NO_RD, NO_WR};
           nextState = NEG1;
           winAddSub = 2'b0;
        end
        NEG1: begin
           out = {F_A_PLUS_1, MUX_REG, 2'bxx, DEST_REG, NO_LOAD, NO_RD, NO_WR};
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        default: begin
           out = 14'bx;
           nextState = FETCH;
           winAddSub = 2'b0;
        end
        winAddSub = 2'b0;
        endcase
      winAddSub = 2'b0;
        end

   winAddSub = 2'b0;
        endmodule
