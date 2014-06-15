//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:18:54 03/10/2013 
// Design Name: 
// Module Name:    counter 
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
module counter(
        rst_i,      
		clk_i,			
		div_i,			
		div_stall,			
		stall_complete,			  //EX_EX_stall_complete,
		stall_counter_o			  //EX_stall_counter
    );
	
input               rst_i;
input               clk_i;
input               div_i;         
input               div_stall; 
input               stall_complete;  
output reg  [31:0]  stall_counter_o;

always @(posedge clk_i or negedge  rst_i)begin
      if(rst_i==0)
	    stall_counter_o<=0;
      else  begin
		  if(div_stall)
		     stall_counter_o <= stall_counter_o-1;			 		 
		  else if(stall_complete)
		     stall_counter_o <= 32;			 		  
		  else 
		     stall_counter_o <= stall_counter_o;			 	       
	 end
      
end

endmodule
