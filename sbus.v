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
// UniCore -- System Bus


module sbus
(
	// system signal
	clk_i,
	rst_n,

	// to Data Cache Interface
	dmem_dat_i, 
	dmem_adr_i, 	
	dmem_stb_i, 
	dmem_we_i,
	//dmem_sel_i,
	dmem_burst_cnt_i,  			// add by csh93 2006/03/09		
	dmem_dat_o, 
	dmem_ack_o, 
	
	// to Instruction Cache Interface
	imem_adr_i, 	
	imem_stb_i, 
	imem_burst_cnt_i,  			// add by csh93 2006/03/09 
	imem_dat_o, 
	imem_ack_o, 	
	
	// to Background Load/Store Interface
	bg_dat_i, 
	bg_adr_i, 	
	bg_stb_i, 
	bg_we_i,
	bg_sel_i,
	bg_burst_cnt_i,  			// add by csh93 2006/03/09  		
	bg_dat_o, 
	bg_ack_o, 
	
	// to AMBA Wrapper Interface, 		
	wrp_dat_i, 
	wrp_ack_i,
	wrp_ack_bus_i,				// add by csh93 2006/03/09 
	wrp_dat_o, 
	wrp_adr_o, 	
	wrp_stb_o, 
	wrp_we_o,
	wrp_sel_o,
	wrp_burst_cnt_o				// add by csh93 2006/03/09 
);

// system signal
input	clk_i;
input	rst_n;

// to Data Cache Interface
input	[31:0]		dmem_dat_i; 
input	[31:0]		dmem_adr_i; 	
input			dmem_stb_i; 
input			dmem_we_i;
//input	[3:0]		dmem_sel_i;
input   [4-1:0]		dmem_burst_cnt_i;                 // add by csh93 2006/03/04		 		
output	[31:0]		dmem_dat_o; 
output			dmem_ack_o; 
	
// to Instruction Cache Interface
input	[31:0]		imem_adr_i; 	
input			imem_stb_i; 
input   [4-1:0]		imem_burst_cnt_i;                 // add by csh93 2006/03/04
output	[31:0]		imem_dat_o; 
output			imem_ack_o; 	
	
// to Background Load/Store Interface
input	[31:0]		bg_dat_i; 
input	[31:0]		bg_adr_i; 	
input			bg_stb_i; 
input			bg_we_i;
input	[3:0]		bg_sel_i;
input   [4-1:0]		bg_burst_cnt_i;                     // add by csh93 2006/03/04 		
output	[31:0]		bg_dat_o; 
output			bg_ack_o;
	
// to AMBA Wrapper Interface, 		
input	[31:0]		wrp_dat_i; 
input			wrp_ack_i;
input			wrp_ack_bus_i;			               // add by csh93 2006/03/06
output	[31:0]		wrp_dat_o; 
output	[31:0]		wrp_adr_o; 	
output			wrp_stb_o;
output			wrp_we_o;
output	[3:0]		wrp_sel_o;
output	[4-1:0]		wrp_burst_cnt_o;                   // add by csh93 2006/03/04


reg	[31:0]		dmem_dat_o; 
reg			dmem_ack_o;

reg	[31:0]		imem_dat_o; 
reg			imem_ack_o;

reg	[31:0]		bg_dat_o; 
reg			bg_ack_o;

reg	[31:0]		wrp_dat_o; 
reg	[31:0]		wrp_adr_o;
reg			wrp_stb_o;
reg			wrp_we_o;
reg	[3:0]		wrp_sel_o;
reg	[4-1:0]		wrp_burst_cnt_o;                   // add by csh93 2006/03/04

// port_lock signal, 2'b00 icache get, 2'b01 dcache get, 2'b10 bg get
reg     [1:0]		port_lock_temp;
reg     [1:0]		port_lock;

// FSM
reg	[2:0]		state;
reg	[2:0]		nextstate;


// six FSM states
parameter	[2:0]	STATE_ICACHE_WAIT	= 3'h0,
			STATE_DCACHE_WAIT	= 3'h1,
			STATE_BG_WAIT		= 3'h2,
			STATE_ICACHE_SERVICE	= 3'h3,
			STATE_DCACHE_SERVICE	= 3'h4,
			STATE_BG_SERVICE	= 3'h5;


// FSM state & port_lock change state
always @(posedge clk_i or negedge rst_n) begin  // 0329, JS Chen: change to synchronous posedge reset trigger

        if(!rst_n) begin
                port_lock_temp	<= 2'b0;
                state		<= 3'b000;
        end
        else begin   
                port_lock_temp	<= port_lock;
                state		<= nextstate; 
        end

end


// poriorty & decide port for which request
always @(state or 
	 imem_stb_i or
	 dmem_stb_i or 
	 bg_stb_i or
	 //wrp_ack_i
	 wrp_ack_bus_i			// add by csh93 2006/03/04
	 ) begin

	case(state)
	// idle state -> wait for request
	STATE_ICACHE_WAIT: begin
				if(dmem_stb_i) begin		// dcache first
					port_lock = 2'b01;
					nextstate = STATE_DCACHE_SERVICE;
				end
				else if(bg_stb_i) begin		// BG unit second
					port_lock = 2'b10;
					nextstate = STATE_BG_SERVICE;
				end
				else if(imem_stb_i) begin	// icache third
					port_lock = 2'b00;
					nextstate = STATE_ICACHE_SERVICE;
				end
				else begin
					port_lock = 2'b00;
					nextstate = STATE_ICACHE_WAIT;
				end
			   end
	// idle state -> wait for request
	STATE_DCACHE_WAIT: begin
				if(bg_stb_i) begin		// BG unit first
					port_lock = 2'b10;
					nextstate = STATE_BG_SERVICE;
				end				
				else if(imem_stb_i) begin	// icache second
					port_lock = 2'b00;
					nextstate = STATE_ICACHE_SERVICE;
				end
				else if(dmem_stb_i) begin	// dcache third
					port_lock = 2'b01;
					nextstate = STATE_DCACHE_SERVICE;
				end
				else begin
					port_lock = 2'b01;
					nextstate = STATE_DCACHE_WAIT;
				end	
			   end
	// idle state -> wait for request
	STATE_BG_WAIT: 	   begin
				if(imem_stb_i) begin		// icache first
					port_lock = 2'b00;
					nextstate = STATE_ICACHE_SERVICE;
				end
				else if(dmem_stb_i) begin	// dcache second
					port_lock = 2'b01;
					nextstate = STATE_DCACHE_SERVICE;
				end
				else if(bg_stb_i) begin		// BG unit third
					port_lock = 2'b10;
					nextstate = STATE_BG_SERVICE;
				end				
				else begin
					port_lock = 2'b10;
					nextstate = STATE_BG_WAIT;
				end	
			   end
	// sevice icache request
	STATE_ICACHE_SERVICE: begin
				if(wrp_ack_bus_i)				// add by csh93 2006/03/04	
					// modify 2006/2/20
					if(imem_stb_i)
						nextstate = STATE_ICACHE_WAIT;
					else
						nextstate = STATE_ICACHE_SERVICE;	
				else
					nextstate = STATE_ICACHE_SERVICE;
				port_lock = 2'b00;
			   end
	// sevice dcache request
	STATE_DCACHE_SERVICE: begin
				if(wrp_ack_bus_i)				// add by csh93 2006/03/04
					// modify 2006/2/20
					if(dmem_stb_i)
						nextstate = STATE_DCACHE_WAIT;
					else
						nextstate = STATE_DCACHE_SERVICE;
				else
					nextstate = STATE_DCACHE_SERVICE;	
				port_lock = 2'b01;
			   end
	// sevice BG unit request
	STATE_BG_SERVICE:  begin
				if(wrp_ack_bus_i)				// add by csh93 2006/03/04
					// modify 2006/2/20
					if(bg_stb_i)
						nextstate = STATE_BG_WAIT;
					else
						nextstate = STATE_BG_SERVICE;
				else
					nextstate = STATE_BG_SERVICE;	
				port_lock = 2'b10;
			   end
	// won't have other FSM		   
	default:	   begin	// won't happen
				nextstate = 3'b000;
				port_lock = 2'b00;
			   end		   			   			   		
	endcase

end


always @(
         port_lock or

	 dmem_dat_i or 
	 dmem_adr_i or
	 dmem_stb_i or
	 dmem_we_i  or
	// dmem_sel_i or
	 dmem_burst_cnt_i or
	 
	 imem_adr_i or	
	 imem_stb_i or 
	 imem_burst_cnt_i or

	 bg_dat_i or
	 bg_adr_i or	
	 bg_stb_i or
	 bg_we_i  or
	 bg_sel_i or
	 bg_burst_cnt_i	or
	 
	 
	 wrp_dat_i or
	 wrp_ack_i 

         ) begin

	case(port_lock)
	
	2'b00: begin	// icache get port
	
		dmem_dat_o = 32'b0; 
		dmem_ack_o = 1'b0;

		imem_dat_o = wrp_dat_i; 
		imem_ack_o = wrp_ack_i;

		bg_dat_o = 32'b0; 
		bg_ack_o = 1'b0;

		wrp_dat_o = 32'b0; 
		wrp_adr_o = imem_adr_i;
		wrp_stb_o = imem_stb_i;
		wrp_we_o  = 1'b0;
		wrp_sel_o = 4'b1111;
		wrp_burst_cnt_o	= imem_burst_cnt_i;
	
		/*
		imem_dat_o = wrp_dat_i; 
		imem_ack_o = wrp_ack_i;

		wrp_dat_o = dmem_dat_i; 
		wrp_adr_o = imem_adr_i;
		//wrp_stb_o = imem_stb_i;
		wrp_stb_o = 1'b1;
		wrp_we_o  = 1'b0;
		wrp_sel_o = 4'b1111;         //32bits
		wrp_burst_cnt_o	= imem_burst_cnt_i;
		*/
		
	end
	2'b01: begin	// dcache get port
			
			
		
		dmem_dat_o = wrp_dat_i; 
		//temp = wrp_dat_i;
		
		
		dmem_ack_o = wrp_ack_i;

		imem_dat_o = 32'b0; 
		imem_ack_o = 1'b0;

		bg_dat_o = 32'b0; 
		bg_ack_o = 1'b0;

		wrp_dat_o = dmem_dat_i; 
		wrp_adr_o = dmem_adr_i+32'h0100_0000;
		wrp_stb_o = dmem_stb_i;
		wrp_we_o  = dmem_we_i;
		wrp_sel_o = 4'b1111;
		wrp_burst_cnt_o	= dmem_burst_cnt_i;			
			
			/*
		dmem_dat_o = wrp_dat_i; 
		dmem_ack_o = wrp_ack_i;

		imem_dat_o = 32'b0; 
		imem_ack_o = 1'b0;

		wrp_dat_o = dmem_dat_i; 
		wrp_adr_o = dmem_adr_i+32'h0100_0000;
		wrp_stb_o = dmem_stb_i;
		wrp_we_o  = dmem_we_i;
		wrp_sel_o = 4'b1111;         //32bits
		wrp_burst_cnt_o	= dmem_burst_cnt_i;	*/
	end
	2'b10: begin	// bg unit get port
	
		dmem_dat_o = 32'b0; 
		dmem_ack_o = 1'b0;

		imem_dat_o = 32'b0; 
		imem_ack_o = 1'b0;

		bg_dat_o = wrp_dat_i; 
		bg_ack_o = wrp_ack_i;

		wrp_dat_o = bg_dat_i; 
		wrp_adr_o = bg_adr_i;
		wrp_stb_o = bg_stb_i;
		wrp_we_o  = bg_we_i;
		wrp_sel_o = bg_sel_i;
		wrp_burst_cnt_o	= bg_burst_cnt_i;		
	
	end
	default: begin	// won't happen
	
		dmem_dat_o = 32'b0; 
		dmem_ack_o = 1'b0;

		imem_dat_o = 32'b0; 
		imem_ack_o = 1'b0;

		bg_dat_o = 32'b0; 
		bg_ack_o = 1'b0;

		wrp_dat_o = 32'b0; 
		wrp_adr_o = 32'b0;
		wrp_stb_o = 1'b0;
		wrp_we_o  = 1'b0;
		wrp_sel_o = 4'b0;
		wrp_burst_cnt_o	= 4'b0;		
	
	end
	
	endcase

end

endmodule
