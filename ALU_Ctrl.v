//Subject:     CO project 2 - ALU Controller
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module ALU_Ctrl(
          funct_i,
          ALUOp_i,
          ALUCtrl_o
          );
          
//I/O ports 
input      [6-1:0] funct_i;
input      [4-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;    
     
//Internal Signals
reg        [4-1:0] ALUCtrl_o;


/*
alu_ctrl:
0000 &
0001 |
0010 +
0110 -
1100 * (mult)
0011 / (div)
0111 A<B? 1:0
0011 shift
0100 shift logic var
0101 load upper imme
0001 or imme  (¸ò or ¬Û¦P)
1111 branch not equal
1000 branch greater than
1001 branch non equal zero
1010 branch greater equal zreo


instr_op_i:
0000  --> arithmetic
0111  --> addi
0001  --> beq
0110  --> slti
0011  --> lui
0100  --> ori
0101  --> bne
0010  --> bgt
1000  --> bnez
1001  --> bgez
1010  --> li
*/
      
//Select exact operation
always @(*)
begin
  if(funct_i==6'b100000 && ALUOp_i==4'b0010)  //add
    ALUCtrl_o = 4'b0010;
  else if(funct_i==6'd24 && ALUOp_i==4'b0010)  //mult
    ALUCtrl_o = 4'b1100;
  else if(funct_i==6'd26 && ALUOp_i==4'b0010)  //div
    ALUCtrl_o = 4'b0011;
  else if(ALUOp_i==4'b0111)  //addi
    ALUCtrl_o = 4'b0010; 
  else if(funct_i==6'b100010 && ALUOp_i==4'b0010)  //sub
     ALUCtrl_o = 4'b0110;
  else if(funct_i==6'b100100 && ALUOp_i==4'b0010)   //and
     ALUCtrl_o = 4'b0000;
  else if(funct_i==6'd37 && ALUOp_i==4'b0010)  //or
     ALUCtrl_o = 4'b0001;
  else if(funct_i==6'b101010 && ALUOp_i==4'b0010)   //slt
     ALUCtrl_o = 4'b0111; 
  else if(ALUOp_i==4'b0110)   //slti
     ALUCtrl_o = 4'b0111;
  else if(ALUOp_i==4'b0010)   //bgt
     ALUCtrl_o = 4'b1000;
  else if(ALUOp_i==4'b1000)   //bnez
     ALUCtrl_o = 4'b1111;  
  else if(ALUOp_i==4'b0001)   //beq
     ALUCtrl_o = 4'b0110;
  else if(ALUOp_i==4'b0101)   //bne
     ALUCtrl_o = 4'b1111;
  else if(funct_i==6'b000000 && ALUOp_i==4'b0010)  //sll
     ALUCtrl_o = 4'b0011;
  else if(funct_i==6'd6 && ALUOp_i==4'b0010)  //sll var
     ALUCtrl_o = 4'b0100;
  else if( ALUOp_i==4'b0011)  //load upper imme
     ALUCtrl_o = 4'b0101;
  else if( ALUOp_i==4'b0100)  //or imme
     ALUCtrl_o = 4'b1000;
  else if( ALUOp_i==4'b0000)  //lw,sw
     ALUCtrl_o = 4'b0010;
  else if(ALUOp_i==4'b1001)    //bgez
     ALUCtrl_o = 4'b1010;
  else  ALUCtrl_o = 4'b0010;
end
endmodule     





                    
                    