//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:31:19 12/17/2011 
// Design Name: 
// Module Name:    Forwarding_unit 
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
module Forwarding_unit(
		MEM_RegWrite,
		WB_RegWrite,
		MEM_target,
		WB_target,
		EX_RS,
		EX_RT,
		Forward_A,
		Forward_B
	);

input 					MEM_RegWrite;
input					WB_RegWrite;
input 	 [5-1:0]		MEM_target;
input    [5-1:0]        WB_target;
input    [5-1:0]		EX_RS;
input    [5-1:0]		EX_RT;
output reg  [2-1:0]		Forward_A;
output reg  [2-1:0]		Forward_B;

always @(*)
begin
	if( MEM_RegWrite && (MEM_target != 0 ) && (EX_RS == MEM_target)) Forward_A =2'b01;
	else if( WB_RegWrite && ( WB_target != 0 ) && ( EX_RS == WB_target ))Forward_A=2'b10;
	else Forward_A = 2'b00;
	
	if( MEM_RegWrite && (MEM_target != 0 ) && (EX_RT == MEM_target)) Forward_B =2'b01;
	else if( WB_RegWrite && ( WB_target != 0 ) && ( EX_RT == WB_target ))Forward_B =2'b10;
	else Forward_B = 2'b00;
end

endmodule
