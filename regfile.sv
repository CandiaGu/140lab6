/*
 * File: regfile.sv
 * Created: 23 October 2009
 * Modules contained: reg_file
 *
 * Update History:
 * 17 April 2013: Made output multiplexers into explicit components (wnace)
 * 17 November 2009: Minor modification to facilitate synthesis (mcbender)
 * 4 November 2009: Minor spacing modifications (mcbender)
 * 23 October 2009: Moved to its own file (mcbender)
 * 12 October 2009: Fixed typo.
 * 7 October 2009: Added demux and updated architecture accordingly
 * 3 October 2009: Removed output port C, cleaned up style a little
 * 9 June 1999 : Added 4 remaining registers 
 * 13 Oct 2010: Updated always to always_comb and always_ff.Renamed to.sv(abeera) 
 * 17 Oct 2010: Updated to use enums instead of define's (iclanton)
*/

/* 
 * module: reg_file
 *
 * The p18240's register file, which currently consists of eight (8)
 * 16-bit registers.  (It has at some points had fewer due to lack of
 * space on various FPGAs.)
 *
 * This register file has three outputs, the two registers A and B used
 * by the processor itself, and a third port for viewing purposes during
 * debugging.
*/
module reg_file(
   output logic [15:0] outA,
   output logic [15:0] outB,
   output logic [127:0] outView,
   input [15:0]      in,
   input [2:0]       selA,
   input [2:0]       selB,
   input             load_L, 
   input             reset_L,
   input             clock,
   input [1:0]       winAddSub);
   
   logic [4:0] index;
   logic [4:0] newIndex;
   logic indexload;
   logic [15:0] pr31,pr30,pr29,pr28,pr27,pr26,pr25,
		pr24,pr23,pr22,pr21,pr20,pr19,pr18,
		pr17,pr16,pr15,pr14,pr13,pr12,pr11,
		pr10,pr9,pr8,pr7,pr6,pr5,pr4,pr3,pr2,pr1,pr0;

   logic [31:0]  reg_enable_lines_L;
   logic [511:0] prwires;
   logic [511:0] preOutView;
   
   register #(.WIDTH(16)) reg0(.out(pr0), .in(in), .load_L(reg_enable_lines_L[0]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg1(.out(pr1), .in(in), .load_L(reg_enable_lines_L[1]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg2(.out(pr2), .in(in), .load_L(reg_enable_lines_L[2]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg3(.out(pr3), .in(in), .load_L(reg_enable_lines_L[3]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg4(.out(pr4), .in(in), .load_L(reg_enable_lines_L[4]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg5(.out(pr5), .in(in), .load_L(reg_enable_lines_L[5]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg6(.out(pr6), .in(in), .load_L(reg_enable_lines_L[6]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg7(.out(pr7), .in(in), .load_L(reg_enable_lines_L[7]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg8(.out(pr8), .in(in), .load_L(reg_enable_lines_L[8]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg9(.out(pr9), .in(in), .load_L(reg_enable_lines_L[9]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg10(.out(pr10), .in(in), .load_L(reg_enable_lines_L[10]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg11(.out(pr11), .in(in), .load_L(reg_enable_lines_L[11]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg12(.out(pr12), .in(in), .load_L(reg_enable_lines_L[12]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg13(.out(pr13), .in(in), .load_L(reg_enable_lines_L[13]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg14(.out(pr14), .in(in), .load_L(reg_enable_lines_L[14]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg15(.out(pr15), .in(in), .load_L(reg_enable_lines_L[15]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg16(.out(pr16), .in(in), .load_L(reg_enable_lines_L[16]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg17(.out(pr17), .in(in), .load_L(reg_enable_lines_L[17]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg18(.out(pr18), .in(in), .load_L(reg_enable_lines_L[18]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg19(.out(pr19), .in(in), .load_L(reg_enable_lines_L[19]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg20(.out(pr20), .in(in), .load_L(reg_enable_lines_L[20]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg21(.out(pr21), .in(in), .load_L(reg_enable_lines_L[21]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg22(.out(pr22), .in(in), .load_L(reg_enable_lines_L[22]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg23(.out(pr23), .in(in), .load_L(reg_enable_lines_L[23]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg24(.out(pr24), .in(in), .load_L(reg_enable_lines_L[24]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg25(.out(pr25), .in(in), .load_L(reg_enable_lines_L[25]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg26(.out(pr26), .in(in), .load_L(reg_enable_lines_L[26]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg27(.out(pr27), .in(in), .load_L(reg_enable_lines_L[27]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg28(.out(pr28), .in(in), .load_L(reg_enable_lines_L[28]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg29(.out(pr29), .in(in), .load_L(reg_enable_lines_L[29]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg30(.out(pr30), .in(in), .load_L(reg_enable_lines_L[30]),
                               .clock(clock), .reset_L(reset_L));
   register #(.WIDTH(16)) reg31(.out(pr31), .in(in), .load_L(reg_enable_lines_L[31]),
                               .clock(clock), .reset_L(reset_L));

   register #(.WIDTH(5)) indexReg(.out(index), .in(newIndex), .load_L(indexload),
                               .clock(clock), .reset_L(reset_L));


   logic [4:0] bigselA;
   logic [4:0] bigselB;
   logic [8:0] bigIndex;

   //assign bigIndex = {0,0,0,0,index};

   assign bigselA = {1'b0,1'b0,selA};
   assign bigselB = {1'b0,1'b0,selB};


   demux #(.OUT_WIDTH(32), .IN_WIDTH(5), .DEFAULT(1))
         reg_en_decoder (.in(load_L), .sel(bigselA + index), .out(reg_enable_lines_L));

   mux32to1 #(.WIDTH(16)) muxA(.bundle(prwires), 
                              .out(outA), .sel(bigselA + index ));

   mux32to1 #(.WIDTH(16)) muxB(.bundle(prwires), 
                              .out(outB), .sel(bigselB + index));

   assign indexload = ((winAddSub == 2'b01)||(winAddSub == 2'b10)) ? 0 : 1;

   always_comb begin  
    	prwires = {pr31,pr30,pr29,pr28,pr27,pr26,pr25,
    		pr24,pr23,pr22,pr21,pr20,pr19,pr18,
    		pr17,pr16,pr15,pr14,pr13,pr12,pr11,
    		pr10,pr9,pr8,pr7,pr6,pr5,pr4,pr3,pr2,pr1,pr0};
    	
    	if(winAddSub == 2'b10)
    	   newIndex = index + 4;
      else
         if(winAddSub == 2'b01)
    	     newIndex = index - 4;
         else
           newIndex = index;

       bigIndex = {1'b0,1'b0,1'b0,1'b0,newIndex};

       $display("index: %d", index);
       $display("newIndex: %d", index);
       $display("bigselA: %d", index);
    	 preOutView = (prwires) >> (bigIndex<<4);
       outView = preOutView[127:0];

       $display("register: %h", preOutView);
   end

endmodule : reg_file
