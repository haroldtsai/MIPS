`timescale 1ns / 1ps
//Subject:     CO project 2 - ALU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module ALU(
     stall_counter_i,
     src1_i,
	 src2_i,
	 src3_i,
	 ctrl_i,
	 temp_a_in,
     temp_b_in,
	 result_o,
	 zero_o,
	 mult_data_o,
	 ALU_stall_o,
	 stall_complete_o,
	 temp_a_out,
	 temp_b_out
	);
     
//I/O ports
input  [32-1:0]  src1_i;
input  [32-1:0]  src2_i;
input  [4-1:0]   ctrl_i;
input  [16-1:0]  src3_i;
input  [64-1:0]  temp_a_in;
input  [32-1:0]  temp_b_in;
input  [32-1:0]  stall_counter_i;
output [32-1:0]  result_o;
output           zero_o;
output [64-1:0]  mult_data_o;
output           ALU_stall_o;
output           stall_complete_o;
output [64-1:0]  temp_a_out;
output [32-1:0]  temp_b_out;
//Internal signals
reg    [32-1:0]  temp;
reg    [32-1:0]  result_o;
wire             zero_o = (result_o==0)? 1:0;
reg    [6-1: 0]  shamt;
reg    [64-1:0]  mult_data_o; 
reg    [64-1:0]  temp_a_out ;
reg    [32-1:0]  temp_b_out ;
//reg              i;
reg              ALU_stall_o;
reg              stall_complete_o;
//reg    [31:0]    test;
//Parameter

//Main function
always @(*)
begin
  result_o         = 0;
  //zero_o           = 0;
  mult_data_o      = 0;
  ALU_stall_o      = 0;
  stall_complete_o = 0;
  temp_a_out       = 0;
  temp_b_out       = 0;
  if(ctrl_i==4'b0000)begin
     result_o = src1_i & src2_i;
	 ALU_stall_o = 0;
	 stall_complete_o = 1;
	 mult_data_o = 0;
  end
  else if(ctrl_i==4'b0001)begin
     result_o = src1_i | src2_i;
	 mult_data_o = 0;
	 ALU_stall_o = 0;
	 stall_complete_o = 1;
  end
  else if(ctrl_i==4'b0010)begin
     result_o = src1_i + src2_i;
	 ALU_stall_o = 0;
	 stall_complete_o = 1;
	 mult_data_o = 0;
  end
  else if(ctrl_i==4'b0011)begin        //div
     if(stall_counter_i==32 )begin   
	    temp_a_out = {32'b0,src1_i};
	    temp_b_out = src2_i;
		stall_complete_o = 0;
		ALU_stall_o = 1;
		mult_data_o = 0;
		result_o = 0;
       //test = 0;		
	  end
	  else if( stall_counter_i >= 0 && stall_counter_i<32 )begin	     	   
		 /*temp_a = {temp_a[62:0],1'b0};		 
     	 if(temp_a[63:32]>=temp_b[63:32]) begin
		     temp_a = temp_a - temp_b + 1'b1;
           //stall_complete_o = 0;
       end			  
		 else  
         temp_a = temp_a;
         //test = test+1;*/
		    temp_a_out = {temp_a_in[62:0],1'b0};
		    temp_b_out = temp_b_in;
    		stall_complete_o = 0;
			result_o = 0;
            ALU_stall_o = 1;
            mult_data_o = 0;			
	  end	  
	  else  begin
	    result_o = 0;  //lv training add 0529
		temp_a_out = {temp_a_in[62:0],1'b0};//lv training add 0529
	    temp_b_out = temp_b_in;
	    stall_complete_o = 1 ;
	    ALU_stall_o = 0;
	    mult_data_o = {temp_a_in[31:0],temp_a_in[63:32]};	  
     end   
  end
  else if(ctrl_i==4'b0110)begin
     result_o = src1_i - src2_i;
	  mult_data_o = 0;
	  ALU_stall_o = 0;
	  stall_complete_o = 1;
  end	  
  else if(ctrl_i==4'b0111)begin
     result_o = (src1_i<src2_i)? 1:0;
	  mult_data_o = 0;
	  ALU_stall_o = 0;
	  stall_complete_o = 1;
  end
  else if(ctrl_i==4'b1100)begin
     	  mult_data_o = src1_i * src2_i;
		  ALU_stall_o = 0;
	     stall_complete_o = 1;
  end
  else if(ctrl_i==4'b1000)begin //bgt
     if(src1_i>src2_i)result_o = 0;
	  else result_o = 1;
	  mult_data_o = 0;
	  ALU_stall_o = 0;
	  // ALU_stall_o = 0;
	  stall_complete_o = 1;
  end
  else if(ctrl_i==4'b0011)begin   //shift
      temp = src3_i & 16'b0000111111000000;
	   shamt = src3_i[10:6];
	   result_o = src2_i<<shamt;
      mult_data_o = 0;
      ALU_stall_o = 0;
	   stall_complete_o = 1;	  
  end
  else if(ctrl_i==4'b0100)begin  //shift var
     result_o = src2_i>>src1_i;
	  mult_data_o = 0;
	  ALU_stall_o = 0;
	  stall_complete_o = 1;
  end 
  else if(ctrl_i==4'b0101)begin  //load upper imme
     result_o = src2_i * 65536;
	  mult_data_o = 0;
	  ALU_stall_o = 0;
	  stall_complete_o = 1;
  end
  else if(ctrl_i==4'b1000)begin  //or imme
     temp = src2_i & 32'b00000000000000001111111111111111;
     result_o = src1_i | temp;
	  mult_data_o = 0;
	  ALU_stall_o = 0;
	  stall_complete_o = 1;
  end
  else if(ctrl_i==4'b1111)begin  //bne
       if(src1_i!=src2_i)
	     result_o = 0;
	    else
	     result_o = 1;
		  mult_data_o = 0;
        ALU_stall_o = 0;
	     stall_complete_o = 1;
  end
  else if(ctrl_i==4'b1010)begin  //bgez
     if(src1_i>=0 && src1_i[31] == 0)
	   result_o = 0;
	  else
	   result_o = 1;
	   mult_data_o = 0;
	   ALU_stall_o = 0;
	   stall_complete_o = 1;
  end
  else begin
	  mult_data_o = 0;
	  ALU_stall_o = 0;
	  stall_complete_o = 1;
	  result_o = 0;
	end
end
endmodule





                    
                    