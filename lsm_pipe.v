module lsm_pipe(
        rst_i,
	    clk_i,
		remain_i,
		data_i,
        data_base_i,		
	    data_o,
		data_base_o
	
	);


input                    rst_i;
input                    clk_i;		 
input      [21-1:0]      data_i;
input      [32-1:0]      data_base_i;
input                    remain_i;
output reg [21-1: 0]     data_o;
output reg [32-1: 0]     data_base_o;
	  
always @(posedge clk_i or negedge  rst_i) begin
	 if( rst_i == 0)begin
	    data_o <= 0;
		data_base_o <= 0;
	 end
	 else if (remain_i )begin
     	 data_o <= data_o;
		 data_base_o <= data_base_o;
	 end	  
    else begin
	    data_o <= data_i;
		data_base_o <= data_base_i+4;
	end
end

endmodule	