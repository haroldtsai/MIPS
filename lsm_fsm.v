module lsm_fsm(
        rst_i,
	    clk_i,
		iack_i,
		data_i,
	    data_o
	);

input    rst_i;
input    clk_i;
input    data_i;
input    iack_i;
output   data_o;
reg      data_o;

	  
always @(posedge clk_i or negedge  rst_i) begin
	 if( rst_i == 0)begin
	   data_o <= 0;
	 end
     else begin
	   if(iack_i)begin
	    if(data_i) data_o <= 1;
		else data_o <= 0;
	   end
	   
	end
end

endmodule