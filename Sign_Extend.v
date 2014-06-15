//Subject:     CO project 2 - Sign extend
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module Sign_Extend(
    data_i,
    data_o
    );
               
//I/O ports
input   [16-1:0] data_i;
output  [32-1:0] data_o;

//Internal Signals
reg     [32-1:0] data_o;

//Sign extended
always @(*)
begin
  data_o[16] = data_i[15];
  data_o[17] = data_i[15];
  data_o[18] = data_i[15];
  data_o[19] = data_i[15];
  data_o[20] = data_i[15];
  data_o[21] = data_i[15];
  data_o[22] = data_i[15];
  data_o[23] = data_i[15];
  data_o[24] = data_i[15];
  data_o[25] = data_i[15];  
  data_o[26] = data_i[15];
  data_o[27] = data_i[15];
  data_o[28] = data_i[15];
  data_o[29] = data_i[15];
  data_o[30] = data_i[15];
  data_o[31] = data_i[15];
  data_o[15:0] = data_i;
end          
endmodule      
     