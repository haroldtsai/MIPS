//+FHDR----------------------------------------------------------------
// (C) Copyright Multimedia SOC Group, SoC Research Center
// Department of Computer Science and Information Engineering
// National Chung Cheng University
// All Right Reserved
//---------------------------------------------------------------------
// FILE NAME       : 
// ORIGINAL AUTHOR : csh93 <csh93@cs.ccu.edu.tw>
//---------------------------------------------------------------------
// RELEASE VERSION     : V0.1
// VERSION DESCRIPTION :
//---------------------------------------------------------------------
// RELEASE DATE: 01-03-2006
//---------------------------------------------------------------------
// PURPOSE:
//---------------------------------------------------------------------
// PARAMETERS:
//PARAMETER NAME         RANGE       DESCRIPTION        DEFAULT VALUE
//
//-FHDR----------------------------------------------------------------
// UniCore -- behavior memory for AMBA interface

`define Mem_Size 1024*1024*64

module	AMBA_behavior(
			 clk_i,
			 rst_n,
			 
			//-----------------------------------------------------------
			// input to AHB                      
			//-----------------------------------------------------------
			 HBUSREQ_i,
			 HADDR_i,
			 HTRANS_i,
			 HSIZE_i,
			 HBUrst_n,
			 HWRITE_i,
			 HWDATA_i,
			 HPROT_i,
			 HLOCK_i,
			 
			//-----------------------------------------------------------
			// output from AHB                     
			//----------------------------------------------------------- 	
			 HGRANT_o,
			 HREADY_o,
			 HRESP_o,
			 HRDATA_o
			 
			 );
			 

// system signal
input	clk_i;
input	rst_n;	

//-----------------------------------------------------------
// input to AHB                      
//-----------------------------------------------------------
input	HBUSREQ_i;
input	[31:0]HADDR_i;
input	[1:0]HTRANS_i;
input	[2:0]HSIZE_i;
input	[2:0]HBUrst_n;	// unuse now
input	HWRITE_i;
input	[31:0]HWDATA_i;
input	[3:0]HPROT_i;	// unuse now
input	HLOCK_i;	// unuse now

//-----------------------------------------------------------
// output from AHB                     
//-----------------------------------------------------------                   
output	HGRANT_o;
output	HREADY_o;
output	[1:0]HRESP_o;	
output	[31:0]HRDATA_o;

reg	HREADY_o;
reg	[31:0]HRDATA_o;

reg	[3:0]byte_select;
			 
// 
// instruction memory
// 
reg	[7:0]inst_mem[0:`Mem_Size-1];


//reg	[3-1:0]counter;
//reg	[3-1:0]counter_t;

// MASTER states:
parameter MASTER_IDLE = 2'b00,  // the master is idle
	  MASTER_REQ  = 2'b01,  // the master requests bus and waits for bus grant
	  MASTER_ADDR = 2'b10,  // the master puts the address and control signals in the bus
	  MASTER_DATA = 2'b11;  // the master reads/write data from the bus
	  
// -----------------------------------------------------------------------------
// Constant declarations
// -----------------------------------------------------------------------------
// HTRANS transfer type signal encoding
parameter TRN_IDLE   = 2'b00;
parameter TRN_NONSEQ = 2'b10;
parameter TRN_SEQ    = 2'b11;
	  
	  
// FSM
reg	[1:0]state;
reg	[1:0]nextstate;

reg	[31:0]HADDR;
reg	HWRITE;
reg	[3:0]byte_select_t;

integer openfile1;

assign	HGRANT_o = (state != MASTER_IDLE)  ? 1'b1 : 1'b0;
assign	HRESP_o  = 2'b00;	// okey for this transfer

/*
assign	byte_select = (HSIZE_i == 3'b000) ? 4'b0001 :
		      (HSIZE_i == 3'b001) ? 4'b0011 :
		      (HSIZE_i == 3'b010) ? 4'b1111 :
		      4'b0000;
*/

always @(HSIZE_i or HADDR_i) begin

	byte_select = 4'b0000;
	
	case(HSIZE_i[1:0])
		2'b00 : begin
			if(HADDR_i[1:0] == 2'b00)
				byte_select = 4'b0001;
			else if(HADDR_i[1:0] == 2'b01)
				byte_select = 4'b0010;
			else if(HADDR_i[1:0] == 2'b10)
				byte_select = 4'b0100;	
			else
				byte_select = 4'b1000;								
		end
		2'b01 : begin
			if(HADDR_i[1:0] == 2'b00)
				byte_select = 4'b0011;
			else if(HADDR_i[1:0] == 2'b10)
				byte_select = 4'b1100;	
			else
				;								
		end
		2'b10 : begin
				byte_select = 4'b1111;								
		end				
	
	endcase

end


initial begin
	openfile1 = $fopen("LS_trace.dat") | 1;
end

// read/write memory
always @(posedge clk_i or negedge rst_n) begin

        if(!rst_n) begin
        	HRDATA_o <= #1 32'b0;
        	HADDR <= #1 32'b0;
        	HWRITE <= #1 1'b0;
        	byte_select_t <= #1 4'b0000;
        end
        else begin   
        	
        	// read
        	if(nextstate == MASTER_DATA & !HWRITE_i) begin
        		//HRDATA_o <= #1  {inst_mem[HADDR_i+3],inst_mem[HADDR_i+2],inst_mem[HADDR_i+1],inst_mem[HADDR_i]};
        		// add by csh93 2006/03/20 - AMBA byte address read
        		HRDATA_o <= #1  {inst_mem[{HADDR_i[31:2], 2'b00}+3],inst_mem[{HADDR_i[31:2], 2'b00}+2],inst_mem[{HADDR_i[31:2], 2'b00}+1],inst_mem[{HADDR_i[31:2], 2'b00}]};
        		//$fdisplay(openfile1, "load %h", HRDATA_o);
        	end
        	// add by csh93 2006/03/07
        	HADDR <= #1 HADDR_i;
        	HWRITE <= #1 HWRITE_i;
        	byte_select_t <= #1 byte_select;
        	
        	
        	// write	
        	//if(nextstate == MASTER_DATA & HWRITE_i) begin
        	//if(state == MASTER_DATA & HWRITE & HTRANS_i == TRN_SEQ) begin        // HTRANS_i == TRN_SEQ **
        	if(state == MASTER_DATA & HWRITE) begin				       // single write
        		/*
        		if(byte_select_t[0])
				inst_mem[HADDR]   <= #1 HWDATA_i[7:0];
			if(byte_select_t[1])
				inst_mem[HADDR+1] <= #1 HWDATA_i[15:8];
			if(byte_select_t[2])
				inst_mem[HADDR+2] <= #1 HWDATA_i[23:16];
			if(byte_select_t[3])
				inst_mem[HADDR+3] <= #1 HWDATA_i[31:24];
			*/
			// add by csh93 2006/03/20 - AMBA byte address write
        		if(byte_select_t[0])
				inst_mem[{HADDR[31:2], 2'b00}]   <= #1 HWDATA_i[7:0];
			if(byte_select_t[1])
				inst_mem[{HADDR[31:2], 2'b00}+1] <= #1 HWDATA_i[15:8];
			if(byte_select_t[2])
				inst_mem[{HADDR[31:2], 2'b00}+2] <= #1 HWDATA_i[23:16];
			if(byte_select_t[3])
				inst_mem[{HADDR[31:2], 2'b00}+3] <= #1 HWDATA_i[31:24];				
			//$fdisplay(openfile1, "store %h", HWDATA_i);	
        	end
        			 
                 
        end

end 

// FSM state
always @(posedge clk_i or negedge rst_n) begin

        if(!rst_n) begin
                state <= #1 2'b00;
                //counter <= #1 3'b000;
        end
        else begin   
                state <= #1 nextstate;
                //counter <= #1 counter_t; 
        end

end

// FSM state
always @ (
	  state or
	  
	  HBUSREQ_i or 
	  HTRANS_i
	  
	  //counter
	  
	  ) begin

  nextstate = state;      // By default it stays in the same state
  HREADY_o  = 1'b1;
  //counter_t = 3'b000;

  case (state)
    
    MASTER_IDLE :
      begin
        if (HBUSREQ_i == 1'b1)
          nextstate = MASTER_REQ;
      end

    MASTER_REQ :                    // Bus request state. Drive SREQ high and wait for SGNT and HREADY high
      begin
      
	HREADY_o  = 1'b1; 
        nextstate = MASTER_ADDR;
         
      end

    MASTER_ADDR :                    // Put address and control signals in the bus, and wait for HREADY high
      begin
        if (HTRANS_i == TRN_NONSEQ) begin
          HREADY_o  = 1'b1;
          nextstate = MASTER_DATA;
        end  
      end

    MASTER_DATA :                    // Put HWDATA in the bus (write transfer). When HREADY goes high, latch HRDATA (read transfer)
      begin
      	// add by csh93 2006/03/06
      	if (HTRANS_i == TRN_SEQ) begin
      		//counter_t = counter + 1'b1;
      		//if(counter == 3'b111) begin
      	  	//	HREADY_o  = 1'b1;  
          	//	nextstate = MASTER_IDLE;
          	//end
          	//else begin
      	  		HREADY_o  = 1'b1;  
          		nextstate = MASTER_DATA;          	
          	//end	
        end
        else begin
      	  	HREADY_o  = 1'b1;  
          	nextstate = MASTER_IDLE;         	
        end
        
      end

    default :
        nextstate = MASTER_IDLE;

  endcase

end	  			 
			 
			 
endmodule			 