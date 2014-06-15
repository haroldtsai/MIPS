//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:50:40 12/17/2011 
// Design Name: 
// Module Name:    Hazard_detection_unit 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Hazard_detection_unit(
        ALU_stall,
	    SWM_stall_i,
        EX_jal,
        EX_j,
		EX_jr,
		PCSrc,
		ID_EX_MemRead,
		loaded_reg,              //rt in load instr
		use_rs,                  //current rs
		use_rt,                  //current rt
		PCWrite,
		IF_ID_remain,
		IF_Flush,
		ID_Flush,
		EX_Flush		
    );
input        	  ALU_stall;
input             SWM_stall_i; 
input             EX_jal;
input             EX_j;
input             EX_jr;	 
input 			  PCSrc;
input			  ID_EX_MemRead;
input		[5-1:0]	loaded_reg;
input		[5-1:0]	use_rs;
input		[5-1:0]	use_rt;

output  reg     IF_ID_remain;
output	reg		PCWrite;
output	reg		IF_Flush;
output	reg		ID_Flush;
output	reg		EX_Flush;

always @ (*)
begin
	if(PCSrc)    //branch
	  begin
			PCWrite = 1'b1;
			IF_Flush = 1'b1;
			ID_Flush = 1'b1;
			EX_Flush = 1'b1;
			IF_ID_remain =1'b0;
	  end
	  else if( EX_jr )   //jr
	  begin
			PCWrite = 1'b1;
			IF_Flush = 1'b1;
			ID_Flush = 1'b1;
			EX_Flush = 1'b0;
			IF_ID_remain =1'b0;
	  end
	  else if( EX_j )   //j
	  begin
			PCWrite = 1'b1;
			IF_Flush = 1'b1;
			ID_Flush = 1'b1;
			EX_Flush = 1'b0;
			IF_ID_remain =1'b0;
	  end
	  else if( EX_jal )   //jal
	  begin
			PCWrite = 1'b1;
			IF_Flush = 1'b1;
			ID_Flush = 1'b1;
			EX_Flush = 1'b0;
			IF_ID_remain =1'b0;
	  end
	  else if(ALU_stall)
	  begin
			PCWrite = 1'b0;
			IF_Flush = 1'b0;
			ID_Flush = 1'b0;
			EX_Flush = 1'b0;
			IF_ID_remain =1'b1;
	  end
	  else if(SWM_stall_i)
	  begin
			PCWrite = 1'b0;
			IF_Flush = 1'b0;
			ID_Flush = 1'b0;
			EX_Flush = 1'b0;
			IF_ID_remain =1'b1;
	  end
	  	else if( ID_EX_MemRead && ((loaded_reg == use_rs) | (loaded_reg == use_rt)))   //load use
	  begin
			PCWrite = 1'b0;
			IF_Flush = 1'b0;
			ID_Flush = 1'b1;
			EX_Flush = 1'b0;
			IF_ID_remain =1'b1;
	  end
	else
	  begin
			PCWrite = 1'b1;
			IF_Flush = 1'b0;
			ID_Flush = 1'b0;
			EX_Flush = 1'b0;
			IF_ID_remain =1'b0;
	  end
end
endmodule
