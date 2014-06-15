module mlsfording(
                  EX_RegWrite_i,
				  MEM_RegWrite_i,
				  WB_RegWrite_i,
				  ID_base_i,
				  EX_target_i,
				  MEM_target_i,
				  WB_target_i,
				  select_o
				  
				);

input                 EX_RegWrite_i;
input 				  MEM_RegWrite_i;
input				  WB_RegWrite_i;
input      [5-1:0]    ID_base_i;
input      [5-1:0]    EX_target_i;
input 	   [5-1:0]	  MEM_target_i;
input      [5-1:0]    WB_target_i;
output reg [2-1:0]    select_o;

always @(*)
begin
    if(EX_RegWrite_i && (EX_target_i != 0 ) && (ID_base_i == EX_target_i))select_o =2'b01;
	else if( MEM_RegWrite_i && (MEM_target_i != 0 ) && (ID_base_i == MEM_target_i)) select_o = 2'b10;
	else if( WB_RegWrite_i && ( WB_target_i != 0 ) && ( ID_base_i == WB_target_i ))select_o = 2'b11;
	else select_o = 2'b00;
	
	
end
endmodule