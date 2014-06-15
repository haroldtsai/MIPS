module lsm_pipe_base(
        rst_i,
	    clk_i,
		data_i,
	    data_o
	);

input    rst_i;
input    clk_i;
input    [32-1:0] data_i;
output   [32-1:0] data_o;
reg      [32-1:0] data_o;

	  
always @(posedge clk_i or negedge  rst_i) begin
	 if( rst_i == 0)begin
	   data_o <= 0;
	 end
     else begin
	     data_o <= data_i;
	end
end
endmodule