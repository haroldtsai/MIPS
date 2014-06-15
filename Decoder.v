//Subject:     CO project 2 - Decoder
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      Luke
//----------------------------------------------
//Date:        2010/8/16
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module Decoder(
    funct_i,
    instr_op_i,
	RegWrite_o,
	ALU_op_o,
	ALUSrc_o,
	RegDst_o,
	Branch_o,
	memread_o,
	memwrite_o,
	memtoreg_o,
	jr_o,
	jump_o,
	jal_o,
	memread_H_o,
    memread_B_o,
	memwrite_H_o,
	memwrite_B_o,
	RegWrite_mult_o,
	mfhi_o,
	mflo_o,
	div_o,
	swm_o
);

//I/O ports
input  [6-1:0]  instr_op_i;
input  [11-1:0] funct_i;
output          RegWrite_o;
output          RegWrite_mult_o;
output [4-1:0]  ALU_op_o;
output          ALUSrc_o;
output          RegDst_o;
output          Branch_o;
output	       jal_o;
output          jump_o;
output          memread_o;
output          memread_H_o;
output          memread_B_o;
output          memwrite_o;
output          memwrite_H_o;
output          memwrite_B_o;
output          memtoreg_o;
output          jr_o;
output          mfhi_o;
output          mflo_o;
output          div_o;
output          swm_o;
//Internal Signals
reg    [4-1:0] ALU_op_o;
reg            ALUSrc_o;
reg            RegWrite_o;
reg            RegWrite_mult_o;
reg            RegDst_o;
reg            Branch_o;
reg            jump_o;
reg            memread_o;
reg            memread_H_o;
reg            memread_B_o;
reg            memwrite_H_o;
reg            memwrite_B_o;
reg            memwrite_o;
reg            memtoreg_o;
reg            jal_o;
reg            jr_o;
reg            mfhi_o;
reg            mflo_o;
reg            div_o;
reg            swm_o;
//Parameter


//Main function
always @(*)
begin
  div_o = 0;
  if(instr_op_i==6'd0&&funct_i==11'd0)
  begin
     ALU_op_o        = 4'b0010; 
     ALUSrc_o        = 1'b0;
     RegWrite_o      = 1'b0;
     RegDst_o        = 1'b0;
     Branch_o        = 1'b0;
     memread_o       = 1'b0;
     memwrite_o      = 1'b0;
     memtoreg_o      = 1'b0;
	 jr_o            = 1'b0;
	 jump_o          = 1'b0;
	 jal_o           = 1'b0;
	 memread_H_o     = 1'b0;
	 memread_B_o     = 1'b0;
	 memwrite_H_o    = 1'b0;
	 memwrite_B_o    = 1'b0;
	 RegWrite_mult_o = 1'b0;
	 mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	 div_o           = 1'b0;
	 swm_o           = 1'b0; 
  end
  else if(instr_op_i==6'd0)    //add,sub,and,or,slt,div	
  begin
     ALU_op_o   = 4'b0010;   /////////////////////////////////////
     ALUSrc_o   = 1'b0;
     //RegWrite_o = (funct_i==6'd8)? 0: 1;//////
	  if(funct_i==6'd8  || funct_i==6'd16 || funct_i==6'd18 )
	    RegWrite_o = 0;
	  else 
	    RegWrite_o = 1;
	  if(funct_i==6'd24  || funct_i==6'd26 )
	    RegWrite_mult_o = 1'b1;
	  else 
	    RegWrite_mult_o = 1'b0;
	 
     RegDst_o   = 1'b1;
     Branch_o   = 1'b0;
     jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b1;
	 jal_o      = 1'b0;
     jr_o          = (funct_i==6'd8)? 1: 0;
     memread_H_o   = 1'b0;
	 memread_B_o   = 1'b0;
     memwrite_H_o  = 1'b0;
	 memwrite_B_o  = 1'b0;
	 div_o         = (funct_i==6'd26)? 1: 0;
     mfhi_o        = (funct_i==6'd16)? 1: 0;
     mflo_o        = (funct_i==6'd18)? 1: 0;
	 swm_o         = 1'b0;
  end
  else if(instr_op_i==6'd28)  //mul
  begin
     ALU_op_o   = 4'b0010;
     ALUSrc_o   = 1'b0;
     RegWrite_o = 1'b1;
     RegDst_o   = 1'b1;
     Branch_o   = 1'b0;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b1;
	  jal_o      = 1'b0;
     jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'd8)  //addi
  begin
     ALU_op_o   = 4'b0111;
     ALUSrc_o   = 1'b1;
     RegWrite_o = 1'b1;
     RegDst_o   = 1'b0;
     Branch_o   = 1'b0;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b1;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'd7)  //bgt
  begin
     ALU_op_o   = 4'b0010;//
     ALUSrc_o   = 1'b0;
     RegWrite_o = 1'b0;
     RegDst_o   = 1'b0;
     Branch_o   = 1'b1;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b1;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'b000100)  //beq
  begin
     ALU_op_o   = 4'b0001;
     ALUSrc_o   = 1'b0;
     RegWrite_o = 1'b0;
     RegDst_o   = 1'b0;
     Branch_o   = 1'b1;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b1;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'd5)  //bne
  begin
     ALU_op_o   = 4'b0101;
     ALUSrc_o   = 1'b0;
     RegWrite_o = 1'b0;
     RegDst_o   = 1'b0;
     Branch_o   = 1'b1;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b1;
     jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'b01010)  //slti
  begin
     ALU_op_o   = 4'b0110;
     ALUSrc_o   = 1'b1;
     RegWrite_o = 1'b1;
     RegDst_o   = 1'b0;
     Branch_o   = 1'b0;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b1;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'd15)  //LUI
  begin
     ALU_op_o   = 4'b0011;
     ALUSrc_o   = 1'b1;
     RegWrite_o = 1'b1;
     RegDst_o   = 1'b0;
     Branch_o   = 1'b0;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b1;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'd13)  //ori
  begin
     ALU_op_o   = 4'b0100;
     ALUSrc_o   = 1'b1;
     RegWrite_o = 1'b1;
     RegDst_o   = 1'b0;
     Branch_o   = 1'b0;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b1;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'b100011)  //lw
  begin
     ALU_op_o   = 4'b0000;
     ALUSrc_o   = 1'b1;
     RegWrite_o = 1'b1;
     RegDst_o   = 1'b0;
     Branch_o   = 1'b0;
	 jump_o     = 1'b0;
     memread_o  = 1'b1;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b0;
	 jal_o      = 1'b0;
	 jr_o       = 1'b0;
	 memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'b111011)  //multiple store(59)
  begin
      ALU_op_o   = 4'b0000;
      ALUSrc_o   = 1'b1;
      RegWrite_o = 1'b0;
      RegDst_o   = 1'b0;
      Branch_o   = 1'b0;
	  jump_o     = 1'b0;
      memread_o  = 1'b0;
      memwrite_o = 1'b0;
      memtoreg_o = 1'b0;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
      mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b1;
  end
  else if(instr_op_i==6'b110011)  //multiple load(51)
  begin
     ALU_op_o   = 4'b0000;
     ALUSrc_o   = 1'b1;
     RegWrite_o = 1'b0;
     RegDst_o   = 1'b0;
     Branch_o   = 1'b0;
	 jump_o     = 1'b0;
     memread_o  = 1'b1;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b0;
	 jal_o      = 1'b0;
	 jr_o       = 1'b0;
	 memread_H_o     = 1'b0;
	 memread_B_o     = 1'b0;
	 memwrite_H_o    = 1'b0;
	 memwrite_B_o    = 1'b0;
	 RegWrite_mult_o = 1'b0;
	 mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	 div_o           = 1'b0;
	 swm_o           = 1'b1;
  end
  else if(instr_op_i==6'b100101)  //lhu opcode37
  begin
     ALU_op_o   = 4'b0000;
     ALUSrc_o   = 1'b1;
     RegWrite_o = 1'b1;
     RegDst_o   = 1'b0;
     Branch_o   = 1'b0;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b0;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b1;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'b100100)  //lbu  opcode36
  begin
     ALU_op_o   = 4'b0000;
     ALUSrc_o   = 1'b1;
     RegWrite_o = 1'b1;
     RegDst_o   = 1'b0;
     Branch_o   = 1'b0;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b0;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b1;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'b101011)  //sw
  begin
     ALU_op_o   = 4'b0000;
     ALUSrc_o   = 1'b1;
     RegWrite_o = 1'b0;
     RegDst_o   = 1'b0;
     Branch_o   = 1'b0;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b1;
     memtoreg_o = 1'b0;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'b101001)  //sh opcode41
  begin
     ALU_op_o   = 4'b0000;
     ALUSrc_o   = 1'b1;
     RegWrite_o = 1'b0;
     RegDst_o   = 1'b0;
     Branch_o   = 1'b0;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b0;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b1;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	 swm_o           = 1'b0;
	  
  end
  else if(instr_op_i==6'b101000)  //sb opcode40
  begin
     ALU_op_o   = 4'b0000;
     ALUSrc_o   = 1'b1;
     RegWrite_o = 1'b0;
     RegDst_o   = 1'b0;
     Branch_o   = 1'b0;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b0;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b1;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'b000010)  //j
  begin
     ALU_op_o   = 4'b0000; //x
     ALUSrc_o   = 1'b1;   //x
     RegWrite_o = 1'b0;   //x
     RegDst_o   = 1'b0;     
     Branch_o   = 1'b0;
	  jump_o     = 1'b1;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b0;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'd5)  //bnez
  begin
     ALU_op_o   = 4'b1000; 
     ALUSrc_o   = 1'b1;   
     RegWrite_o = 1'b0;   
     RegDst_o   = 1'b0;     
     Branch_o   = 1'b1;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b1;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'd1)  //bgez
  begin
     ALU_op_o   = 4'b1001; 
     ALUSrc_o   = 1'b1;   
     RegWrite_o = 1'b0;   
     RegDst_o   = 1'b0;     
     Branch_o   = 1'b1;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b1;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
  else if(instr_op_i==6'b000011)  //jal   /////////////////////////////////////////
  begin
     ALU_op_o   = 4'b0000; 
     ALUSrc_o   = 1'b1;   
     RegWrite_o = 1'b1;   
     RegDst_o   = 1'b1;     
     Branch_o   = 1'b0;
	 jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b0;
	 jal_o      = 1'b1;
	 jr_o       = 1'b0;
	 memread_H_o     = 1'b0;
	 memread_B_o     = 1'b0;
	 memwrite_H_o    = 1'b0;
	 memwrite_B_o    = 1'b0;
	 RegWrite_mult_o = 1'b0;
	 mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	 div_o           = 1'b0;
	 swm_o           = 1'b0;
  end
  else
  begin
     ALU_op_o   = 4'b0000; 
     ALUSrc_o   = 1'b0;   
     RegWrite_o = 1'b0;   
     RegDst_o   = 1'b0;     
     Branch_o   = 1'b0;
	  jump_o     = 1'b0;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b0;
	  jal_o      = 1'b0;
	  jr_o       = 1'b0;
	  memread_H_o     = 1'b0;
	  memread_B_o     = 1'b0;
	  memwrite_H_o    = 1'b0;
	  memwrite_B_o    = 1'b0;
	  RegWrite_mult_o = 1'b0;
	  mfhi_o          = 1'b0;
     mflo_o          = 1'b0;
	  div_o           = 1'b0;
	  swm_o           = 1'b0;
  end
end

  /*else if(instr_op_i==6'b000010)  //j
  begin
     ALU_op_o   = 4'b0000; //x
     ALUSrc_o   = 1'b1;   //x
     RegWrite_o = 1'b0;   //x
     RegDst_o   = 1'b0;     
     Branch_o   = 1'b0;
	  jump_o     = 1'b1;
     memread_o  = 1'b0;
     memwrite_o = 1'b0;
     memtoreg_o = 1'b0;
	//  jal_o = 0;
	  jr_o       = 1'b0;
  end*/




endmodule





                    
                    