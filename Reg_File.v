//Subject:     CO project 4 - Register File
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Reg_File(
     clk_i,              //clk_i,
	 rst_i,              //rst_i,
     RSaddr_i,           //ID_instr[25:21],
     RTaddr_i,           //ID_instr[20:16],
	 RDaddr_mf_i,        //ID_instr[15:11],
	 mfhi_i,             //ID_mfhi, 
	 mflo_i,             //ID_mflo,  
     RDaddr_i,           //WB_WriteReg,
     RDdata_i,           //WB_WriteRegPcData,
     RegWrite_i,          //RegWrite,
	 RegWrite_mult_i,     //WB_RegWrite_mult,
	 RegWrite_mult_MEM_i, //MEM_RegWrite_mult,
	 RegWrite_mult_EX_i,  //EX_RegWrite_mult,
	 mult_data_WB_i,      //WB_ALU_mult_data,
	 mult_data_MEM_i,     //MEM_ALU_mult_data,
	 mult_data_EX_i,      //EX_ALU_mult_data,
     RSdata_o,            //ID_Read_data_1,
     RTdata_o             //ID_Read_data_2
    );
	  
//I/O ports
input           clk_i;
input           rst_i;
input           mfhi_i;
input           mflo_i;
input           RegWrite_i;
input           RegWrite_mult_i;
input           RegWrite_mult_MEM_i;
input           RegWrite_mult_EX_i;
input  [5-1:0]  RSaddr_i;
input  [5-1:0]  RTaddr_i;
input  [5-1:0]  RDaddr_i;
input  [5-1:0]  RDaddr_mf_i;
input  [32-1:0] RDdata_i;
input  [64-1:0] mult_data_WB_i;
input  [64-1:0] mult_data_MEM_i;
input  [64-1:0] mult_data_EX_i;        
output [32-1:0] RSdata_o;
output [32-1:0] RTdata_o;   

//Internal signals/registers           
reg  signed [32-1:0] Reg_File [0:32-1];     //32 word registers
reg  signed [32-1:0] Reg_lo;
reg  signed [32-1:0] Reg_hi;
//reg  signed [32-1:0] counter;
//reg        test;
wire        [32-1:0] RSdata_o;
wire        [32-1:0] RTdata_o;

//Read the data
assign RSdata_o = Reg_File[RSaddr_i] ;
assign RTdata_o = Reg_File[RTaddr_i] ;   

//Writing data when negedge clk_i and RegWrite_i was set.
always @( negedge clk_i or negedge rst_i) begin
    if(rst_i == 0) begin
	    Reg_File[0]  <= 0; Reg_File[1]  <= 0; Reg_File[2]  <= 0; Reg_File[3]  <= 0;
	    Reg_File[4]  <= 0; Reg_File[5]  <= 0; Reg_File[6]  <= 0; Reg_File[7]  <= 0;
        Reg_File[8]  <= 0; Reg_File[9]  <= 0; Reg_File[10] <= 0; Reg_File[11] <= 0;
	    Reg_File[12] <= 0; Reg_File[13] <= 0; Reg_File[14] <= 0; Reg_File[15] <= 0;
        Reg_File[16] <= 0; Reg_File[17] <= 0; Reg_File[18] <= 0; Reg_File[19] <= 0;      
        Reg_File[20] <= 0; Reg_File[21] <= 0; Reg_File[22] <= 0; Reg_File[23] <= 0;
        Reg_File[24] <= 0; Reg_File[25] <= 0; Reg_File[26] <= 0; Reg_File[27] <= 0;
        Reg_File[28] <= 0; Reg_File[29] <= 0; Reg_File[30] <= 0; Reg_File[31] <= 0;
		Reg_lo       <= 0;
		Reg_hi       <= 0;
		 //test <= 0;
	end
   else begin
	
	   
		  
        if(RegWrite_i && RegWrite_mult_i)begin		  //
            Reg_lo <= mult_data_WB_i[31:0];                //
            Reg_hi <= mult_data_WB_i[63:32];	              //
		end	

		
		if(mflo_i && RegWrite_mult_EX_i)                        //lo forwarding from EX
		      Reg_File[RDaddr_mf_i] <= mult_data_EX_i[31:0];
		else if(mfhi_i && RegWrite_mult_EX_i)                   //hi forwarding from EX
		      Reg_File[RDaddr_mf_i] <= mult_data_EX_i[63:32];
        else if(mflo_i && RegWrite_mult_MEM_i)                  //lo forwarding from MEM
		      Reg_File[RDaddr_mf_i] <= mult_data_MEM_i[31:0];
		else if(mfhi_i && RegWrite_mult_MEM_i)                  //hi forwarding from MEM
		      Reg_File[RDaddr_mf_i] <= mult_data_MEM_i[63:32];					
		else if(mflo_i && RegWrite_mult_i)                      //lo from WB
		      Reg_File[RDaddr_mf_i] <= mult_data_WB_i[31:0];
		else if(mfhi_i && RegWrite_mult_i)                      //hi from WB
		      Reg_File[RDaddr_mf_i] <= mult_data_WB_i[63:32];   
		else if(mflo_i)                                         //lo from reg_lo
		      Reg_File[RDaddr_mf_i] <= Reg_lo;
        else if(mfhi_i)		                                    //hi from reg_hi
			  Reg_File[RDaddr_mf_i] <= Reg_hi;  
			  
        if(RegWrite_i&&(!RegWrite_mult_i)) 
            Reg_File[RDaddr_i] <= RDdata_i;					
		else 
		    Reg_File[RDaddr_i] <= Reg_File[RDaddr_i];
		
		  
		  
	end
end
endmodule     





                    
                    