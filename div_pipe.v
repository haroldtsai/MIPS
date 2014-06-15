module div_pipe(
        rst_i,
	    clk_i,
		data_i_1,
		data_i_2,		   	
	    data_o_1,
	    data_o_2
	);


input                    rst_i;
input                    clk_i;		 
input      [64-1: 0]     data_i_1;
input      [32-1: 0]     data_i_2;
output reg [64-1: 0]     data_o_1;
output reg [32-1: 0]     data_o_2;
	  
always @(posedge clk_i or negedge  rst_i) begin
	 if( rst_i == 0)begin
	   data_o_1 <= 0;
	   data_o_2 <= 0;
	 end
    else begin
	    if(data_i_1[63:32]>=data_i_2)begin		
		    data_o_1 <= data_i_1 - {data_i_2,32'b0} + 1'b1;
			data_o_2 <= data_i_2;
		end
		else begin
		    data_o_1 <= data_i_1;
			data_o_2 <= data_i_2;
	    end
	end
end

endmodule	


		