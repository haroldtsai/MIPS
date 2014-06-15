`timescale 1ns / 1ps
module AddrCodeDecoder(

       //clk_i,
	   rst_i,       
	   RS_base_i,
	   addrcode_i,
	   base_i,
	   swm_i,
	   addrcode_o,
	   stall_o,
	   target_o,
       base_o,
       memwrite, 	   
	   regwrite
	   
	   );
  

/* input */
//input           clk_i;
input           rst_i;
input           swm_i;
input  [32-1:0]	RS_base_i;
input  [32-1:0] base_i;
input  [21-1:0] addrcode_i;
/*output*/
output          stall_o;
output [5-1:0]  target_o;
output [32-1:0] base_o;
output [21-1:0] addrcode_o;
output          memwrite;
output          regwrite;
/*reg*/
reg    [32-1:0] base_o;
reg    [5-1:0]  target_o;    
reg             stall_o;
reg    [21-1:0] addrcode_o;
reg             memwrite;
reg             regwrite;        
/*always*/
always @(*)begin
    base_o        =  0;	   
	target_o      =  0;
	addrcode_o    =  0;
	stall_o       =  0;
	memwrite      =  0;
	regwrite      =  0;	    
  if(swm_i)begin
	if(addrcode_i & 21'b000000000000000000001)begin
       base_o        = base_i;
       target_o      = 0;
       //first_time    = 0;
       addrcode_o    = addrcode_i & ~21'b000000000000000000001;
       stall_o       = 1; 
       memwrite      = 1;
	    regwrite      = 1;	   
    end
    else if(addrcode_i & 21'b000000000000000000010)begin
       base_o        = base_i;
       target_o      = 1;
	   //first_time    = 0;
	   addrcode_o    = addrcode_i & ~21'b000000000000000000010; 
	   stall_o       = 1;
	   memwrite      = 1;
	   regwrite      = 1;
    end
    else if(addrcode_i & 21'b000000000000000000100)begin
       base_o        = base_i;
       target_o      = 2;
	   //first_time    = 0;
	   addrcode_o    = addrcode_i & ~21'b000000000000000000100;
	   stall_o       = 1;
	   memwrite      = 1;
	   regwrite      = 1;
    end
    else if(addrcode_i & 21'b000000000000000001000)begin
       base_o        = base_i;
       target_o      = 3;
	   //first_time    = 0;
	   addrcode_o    = addrcode_i & ~21'b000000000000000001000;
	   stall_o       = 1;
	   memwrite      = 1;
	   regwrite      = 1;
    end
    else if(addrcode_i & 21'b000000000000000010000)begin
        base_o        = base_i;
       target_o     = 4;
	   //first_time   = 0;
	   addrcode_o   = addrcode_i & ~21'b000000000000000010000;
	   stall_o      = 1;
	   memwrite     = 1;
	   regwrite     = 1;
    end
	else if(addrcode_i & 21'b000000000000000100000)begin
        base_o        = base_i;
       target_o     = 5;
	   //first_time   = 0;
	   addrcode_o   = addrcode_i & ~21'b000000000000000100000;
	   stall_o      = 1;
	   memwrite     = 1;
	   regwrite     = 1;
    end
	else if(addrcode_i & 21'b000000000000001000000)begin
        base_o        = base_i;
       target_o     = 6;
	   //first_time   = 0;
	   addrcode_o   = addrcode_i & ~21'b000000000000001000000;
	   stall_o      = 1;
	   memwrite     = 1;
	   regwrite     = 1;
    end
	else if(addrcode_i & 21'b000000000000010000000)begin
          base_o        = base_i;
       target_o     = 7;
	   //first_time   = 0;
	   addrcode_o   = addrcode_i & ~21'b000000000000010000000;
	   stall_o      = 1;
	   memwrite     = 1;
	   regwrite     = 1;
    end
	else if(addrcode_i & 21'b000000000000100000000)begin
         base_o        = base_i;
        target_o     = 8;
	    //first_time   = 0;
	    addrcode_o   = addrcode_i & ~21'b000000000000100000000;
	    stall_o      = 1;
	    memwrite     = 1;
	    regwrite     = 1;
    end
	else if(addrcode_i & 21'b000000000001000000000)begin
      base_o        = base_i;
      target_o      = 9;
	   //first_time   = 0;
	   addrcode_o   = addrcode_i & ~21'b000000000001000000000;
	   stall_o      = 1;
      memwrite     = 1;
      regwrite     = 1;
    end
	else if(addrcode_i & 21'b000000000010000000000)begin
         base_o        = base_i;
       target_o     = 10;
	   //first_time   = 0;
	   addrcode_o   = addrcode_i & ~21'b000000000010000000000;
	   stall_o      = 1;
       memwrite     = 1;
	   regwrite     = 1;
    end
	else if(addrcode_i & 21'b000000000100000000000)begin
         base_o        = base_i;
       target_o     = 11;
	   //first_time   = 0;
	   addrcode_o   = addrcode_i & ~21'b000000000100000000000;
	   stall_o      = 1;
	   memwrite     = 1;
	   regwrite     = 1;
    end
	else if(addrcode_i & 21'b000000001000000000000)begin
         base_o        = base_i;
       target_o     = 12;
	   //first_time   = 0;
	   addrcode_o   = addrcode_i & ~21'b000000001000000000000;
	   stall_o      = 1;
	   memwrite     = 1;regwrite = 1;
    end
	else if(addrcode_i & 21'b000000010000000000000)begin
         base_o        = base_i;
       target_o     = 13;
	   //first_time   = 0;
	   addrcode_o   = addrcode_i & ~21'b000000010000000000000;
	   stall_o      = 1;
	   memwrite     = 1;
	   regwrite     = 1;
    end
	else if(addrcode_i & 21'b000000100000000000000)begin
         base_o        = base_i;
       target_o     = 14;
	   //first_time   = 0;
	   addrcode_o   = addrcode_i & ~21'b000000100000000000000;
	   stall_o      = 1;
	   memwrite     = 1;
	   regwrite     = 1;
    end
	else if(addrcode_i & 21'b000001000000000000000)begin
         base_o        = base_i;
       target_o     = 15;
	   //first_time   = 0;
	   addrcode_o   = addrcode_i & ~21'b000001000000000000000;
	   stall_o      = 1;
	   memwrite     = 1;
	   regwrite     = 1;
    end
	else if(addrcode_i & 21'b000010000000000000000)begin
         base_o        = base_i;
       target_o     = 16;
	   //first_time   = 0;
	   addrcode_o   = addrcode_i & ~21'b000010000000000000000;
	   stall_o      = 1;
	   memwrite     = 1;
	   regwrite     = 1;
    end
	else if(addrcode_i & 21'b000100000000000000000)begin
         base_o        = base_i;
       target_o     = 17;
	   //first_time   = 0;
	   addrcode_o   = addrcode_i & ~21'b000100000000000000000;
	   stall_o      = 1;
	   memwrite     = 1;
	   regwrite     = 1;
    end
	else if(addrcode_i & 21'b001000000000000000000)begin
         base_o        = base_i;
       target_o      = 18;
	   //first_time    = 0;
	   addrcode_o    =addrcode_i & ~21'b001000000000000000000;
	   stall_o       = 1;
	   memwrite      = 1;
	   regwrite      = 1;
    end
	else if(addrcode_i & 21'b010000000000000000000)begin
         base_o        = base_i;
       target_o     = 19;
	   //first_time   = 0;
	   addrcode_o   = addrcode_i & ~21'b010000000000000000000;
	   stall_o      = 1;
	   memwrite     = 1;
	   regwrite     = 1;
    end
	else if(addrcode_i & 21'b100000000000000000000)begin
      base_o        = base_i;
      target_o     = 20;
	   //first_time   = 0;
	   addrcode_o   = addrcode_i & ~21'b100000000000000000000;
	   stall_o      = 1;
	   memwrite     = 1;
	   regwrite     = 1;
    end
    else if(addrcode_i==0)begin
      base_o     = base_i;
	   //first_time = 1;
	   stall_o    = 0;
	   target_o   = 0;
	   memwrite   = 0;
	   regwrite   = 0;
	   addrcode_o = 0;
    end
  end
  else begin
      base_o        =  0;	   
	   target_o      =  0;
	   addrcode_o    =  0;
	   stall_o       =  0;
		memwrite      =  0;
	   regwrite      =  0;	
  end     
end
endmodule
       