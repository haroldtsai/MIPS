// +FHDR ----------------------------------------------------------------
// Copyright (C) 2005, CCU SoC LAB Confidential  Proprietary
//-----------------------------------------------------------------------
// Filename         : AHB_master_wrapper.v
//-----------------------------------------------------------------------
// Department       : SoC LAB
// Author           : $Author: nsrta
//-----------------------------------------------------------------------
// Version          : $Revision: 1.0 $
// Last Modified On : $Date: 2006/08/23 
// Last Modified By : $Author: nsrta
//-----------------------------------------------------------------------
// Description      :
//                    AHB master wrapper
// ----------------------------------------------------------------------
// Modification List:
//   o 
// -FHDR ----------------------------------------------------------------


`define BASE_ADDRESS 32'h0400_0000 // 0x04000000 is SDRAM memory map on versatile 

module AHB_master_wrapper(
                        // system signal
                        clk_i,
                        rst_n,
                        Wake_Flag,

                        // AMBA master interface
                        // ---------------- Outputs ------------------
                        // IO
                        HBUSREQ_o,              // master to bus request
                        HADDR_o,                // 32-bit system address
                        HTRANS_o,               // indicate type of the current transfer
                        HSIZE_o,                // indicate size of transfer
                        HBURST_o,               // indicate if the transfer forms part of a burst
                        HWRITE_o,               // 1'b1 is write transfer, 1'b0 is low transfer
                        HWDATA_o,               // write data
                        HPROT_o,                // protection control
                        HLOCK_o,                // 1'b1 is lock accesses

                        // ---------------- Inputs ------------------
                        // IO
                        //HCLK,
                        //HRESETn,
                        HGRANT_i,               // indicates that bus master x is currently the highest priority master
                        HREADY_i,               //
                        HRESP_i,                //
                        HRDATA_i,               // read data

                        // system bus interface
                        // ---------------- Outputs ------------------
                        wrp_dat_o,
                        wrp_ack_o,
                        wrp_ack_bus_o,

                        // ---------------- Inputs ------------------
                        wrp_dat_i,
                        wrp_adr_i,
                        wrp_stb_i,
                        wrp_we_i,
                        wrp_sel_i,
                        wrp_burst_cnt_i
                        );

// system signal
input   clk_i;
input   rst_n;

input   Wake_Flag; // Flag for RISC run or not


//-----------------------------------------------------------
// AMBA master interface
//-----------------------------------------------------------
input           HGRANT_i;
input           HREADY_i;
input   [ 1:0]  HRESP_i;
input   [31:0]  HRDATA_i;

output          HBUSREQ_o;
output  [31:0]  HADDR_o;
output  [ 1:0]  HTRANS_o;
output  [ 2:0]  HSIZE_o;
output  [ 2:0]  HBURST_o;
output          HWRITE_o;
output  [31:0]  HWDATA_o;
output  [ 3:0]  HPROT_o;
output          HLOCK_o;

//output  [3:0] LED;

reg     [ 2:0]  HSIZE_o;
wire            HBUSREQ_o;
wire            HLOCK_o;

//-----------------------------------------------------------
// system bus interface
//-----------------------------------------------------------
input   [31:0]  wrp_dat_i;
input   [31:0]  wrp_adr_i;
input           wrp_stb_i;
input           wrp_we_i;
input   [ 3:0]  wrp_sel_i;
input   [ 3:0]  wrp_burst_cnt_i;

output  [31:0]  wrp_dat_o;
output          wrp_ack_o;
output          wrp_ack_bus_o;

reg      [31:0] wrp_dat_o;
reg             wrp_ack_o;
reg             wrp_ack_bus_o;


// MASTER states:
parameter MASTER_IDLE = 2'b00;  // the master is idle
parameter MASTER_REQ  = 2'b01;  // the master requests bus and waits for bus grant
parameter MASTER_ADDR = 2'b10;  // the master puts the address and control signals in the bus
parameter MASTER_DATA = 2'b11;  // the master reads/write data from the bus

// HTRANS transfer type signal encoding
parameter TRN_IDLE   = 2'b00;
parameter TRN_NONSEQ = 2'b10;
parameter TRN_SEQ    = 2'b11;


// FSM
reg     [1:0] state;                // FSM state
reg     [1:0] nextstate;            // FSM nexstate

reg     [2:0] counter;              // busrt transfer counter
reg     [2:0] counter_t;            // busrt transfer temp counter

reg     [3:0] burst_count;          // busrt transfer count


// AMBA spec: Bursts must not cross a 1kB address boundary.
// if transfer will cross 1kB boundary, use boundary_count for no burst transfer.
reg     [3:0] boundary_count;       // boundary count
reg     [2:0] boundary_counter;     // boundary counter
reg     [2:0] boundary_counter_t;   // boundary temp counter

wire    [2:0] address_counter;      // busrt transfer counter or boundary counter

reg [31:0] HADDRt;                  // temp HADDR


assign HBURST_o = 3'b001;           // INCR
assign HPROT_o  = 4'b0001;          // Data access, not cacheable/bufferable, in privileged mode
assign HWRITE_o = wrp_we_i;         // Type of access (read/write) from logic tile switches


assign HTRANS_o = (state == MASTER_ADDR) ? TRN_NONSEQ :
                  (state == MASTER_DATA & {1'b0, counter} != (burst_count - 1'b1)) ? TRN_SEQ :         // modify 200600404
                  TRN_IDLE;


assign HADDR_o = HADDRt + `BASE_ADDRESS;

// choose HADDR
always@(wrp_adr_i or state or wrp_we_i or address_counter)
begin
    if(wrp_adr_i[1:0]==2'b00) // 若address是對齊word
    begin
        if(state == MASTER_DATA) // burst mode address pre-calculate
            HADDRt = wrp_adr_i + 3'b100 ;
        else
            HADDRt = wrp_adr_i;
    end
    else // 若address非對齊word
    begin
        if(wrp_we_i)
        begin            
            if(state == MASTER_DATA)
                HADDRt = wrp_adr_i + address_counter + 1'b1;
            else
                HADDRt = wrp_adr_i + address_counter;          
        end
        else
        begin
            // 讀非對齊word data時，固定讀兩個word來合併
            if (state == MASTER_DATA)
                HADDRt = {wrp_adr_i[31:2] + address_counter + 1'b1,2'b00};
            else
                HADDRt = {wrp_adr_i[31:2] + address_counter,2'b00};
        end
    end
end


// choose burst transfer counter or boundary counter
assign address_counter = (boundary_count == 4'b0000) ? counter : boundary_counter;


always@(wrp_adr_i or wrp_burst_cnt_i or wrp_we_i or wrp_sel_i)
begin
    boundary_count = 4'b0000;
    
    if(wrp_burst_cnt_i==4'b0100 && wrp_adr_i[9:4]==6'b111111) //若是load instruction且有可能cross 1kB boundary
    begin
        //不busrt 但抓四個word
        burst_count = 4'b0001;
        HSIZE_o = 3'b010;
        boundary_count = 4'b0100;
    end
    else if(wrp_adr_i[1:0]==2'b00) //若是對齊word
    begin
        //若是指令就會burst，data就不會用burst
        burst_count = wrp_burst_cnt_i;  
        case(wrp_sel_i)
                4'b0001 : HSIZE_o = 3'b000;
                4'b0011 : HSIZE_o = 3'b001;
                4'b1111 : HSIZE_o = 3'b010;
                default : HSIZE_o = 3'b010;
        endcase              
        
    end
    else if(wrp_adr_i[9:2]==8'b11111111) //若是load data且有可能cross 1kB boundary
    begin
        if(wrp_we_i)
        begin
            //不busrt
            burst_count = 4'b0001;
            HSIZE_o = 3'b000;
            case(wrp_sel_i)
                    4'b0001 : boundary_count = 4'b0001;
                    4'b0011 : boundary_count = 4'b0010;
                    4'b1111 : boundary_count = 4'b0100;
                    default : boundary_count = 4'b0100;
            endcase            
        end
        else
        begin
            //固定讀兩個word來合併
            burst_count = 4'b0001;
            HSIZE_o = 3'b010;
            boundary_count = 4'b0010;
        end    
    end    
    else
    begin
    
        if(wrp_we_i)
        begin      
            case(wrp_sel_i)
                    4'b0001 : burst_count = 4'b0001;
                    4'b0011 : burst_count = 4'b0010;
                    4'b1111 : burst_count = 4'b0100;
                    default : burst_count = 4'b0100;
            endcase           
            HSIZE_o = 3'b000;              
        end
        else
        begin
            burst_count = 4'b0010;
            HSIZE_o = 3'b010;            
        end
        
    end
    
    
end


reg     [63:0]  HWDATAt; //暫存shift的值

always @(wrp_dat_i or wrp_adr_i) begin

        HWDATAt = 64'b0;

        case(wrp_adr_i[1:0])
                2'b00 : HWDATAt[31: 0] = wrp_dat_i;
                2'b01 : HWDATAt[39: 8] = wrp_dat_i;
                2'b10 : HWDATAt[47:16] = wrp_dat_i;
                2'b11 : HWDATAt[55:24] = wrp_dat_i;
        endcase

end


wire [2:0] HWDATAp; //判斷現在寫的address是data的上半部還是下半部

assign HWDATAp = wrp_adr_i[1:0] + address_counter;
assign HWDATA_o = (HWDATAp[2]==1'b1)? HWDATAt[63:32] : HWDATAt[31:0];


reg     [31:0] HRDATAt; //暫存第一筆的HRDATA
reg     [63:0] wrp_dat_o_t; //暫存合併shift的值


always @(posedge clk_i or negedge rst_n) begin 

        if(!rst_n) begin
            HRDATAt <= 32'b0;
        end
        else begin
            if(address_counter == 3'b000)
                HRDATAt <= HRDATA_i;
            else
                HRDATAt <= HRDATAt;
        end
end

/*
//暫存第一筆的HRDATA (用latch存) -> 會有latch電路
always @(address_counter or HRDATA_i) begin 
            if(address_counter == 3'b000)
                HRDATAt = HRDATA_i;
end
*/

//暫存合併shift的值
always@(address_counter or HRDATA_i or wrp_adr_i or HRDATAt)
begin

    wrp_dat_o_t = 64'b0;
    
    if(wrp_adr_i[1:0]==2'b00)
    begin
        wrp_dat_o_t = {32'b0,HRDATA_i};
    end
    else    
    begin
        if(address_counter == 3'b000)
        begin
            case(wrp_adr_i[1:0])
                2'b00 : wrp_dat_o_t = {32'b0,HRDATA_i};
                2'b01 : wrp_dat_o_t = {32'b0,HRDATA_i} >> 8;
                2'b10 : wrp_dat_o_t = {32'b0,HRDATA_i} >> 16;
                2'b11 : wrp_dat_o_t = {32'b0,HRDATA_i} >> 24;
            endcase                
        end
        else
        begin
            case(wrp_adr_i[1:0])
                2'b00 : wrp_dat_o_t = {HRDATA_i,HRDATAt};
                2'b01 : wrp_dat_o_t = {HRDATA_i,HRDATAt} >> 8;
                2'b10 : wrp_dat_o_t = {HRDATA_i,HRDATAt} >> 16;
                2'b11 : wrp_dat_o_t = {HRDATA_i,HRDATAt} >> 24;
            endcase                
        end  
        
    end
 
    
end   



//把沒有用到的data補0
always@(wrp_sel_i or wrp_dat_o_t or wrp_ack_o)
begin
        if(wrp_ack_o)
            case(wrp_sel_i)
                    4'b0001 : wrp_dat_o = {24'b0,wrp_dat_o_t[7:0]};
                    4'b0011 : wrp_dat_o = {16'b0,wrp_dat_o_t[15:0]};
                    4'b1111 : wrp_dat_o = wrp_dat_o_t[31:0];
                    default : wrp_dat_o = wrp_dat_o_t[31:0];
            endcase 
        else
            wrp_dat_o = 32'b0;
end
            
/*
//有request時 就發出HLOCK
always @(posedge clk_i) begin

    if(rst_n)
        HLOCK_o <= 1'b0;
    else begin
        if(wrp_stb_i)
            HLOCK_o <= 1'b1;
        else
            HLOCK_o <= 1'b0;
    end

end
*/

// FSM state
always @(posedge clk_i or negedge rst_n) begin 

        if(!rst_n) begin
                state <= 2'b00;
                counter <= 3'b0;
                boundary_counter <= 3'b0;
        end
        else begin
                state <= nextstate;
                counter <= counter_t;
                boundary_counter <= boundary_counter_t;
        end

end

// FSM state
always @ (
          state or

          wrp_stb_i or
          burst_count or

          HGRANT_i or
          HREADY_i or
          HRESP_i  or

          counter or
          boundary_counter or
          boundary_count or
          wrp_burst_cnt_i or
          Wake_Flag

          ) begin

  nextstate = state;      // By default it stays in the same state
  wrp_ack_o = 1'b0;
  wrp_ack_bus_o = 1'b0;

  counter_t = 3'b000;
  boundary_counter_t = 3'b000;
  
  case (state)

    MASTER_IDLE :
      begin
        if (wrp_stb_i == 1'b1 & Wake_Flag == 1'b0)
          nextstate = MASTER_REQ;
        boundary_counter_t = boundary_counter;  
      end

    MASTER_REQ :                    // Bus request state. Drive SREQ high and wait for SGNT and HREADY high
      begin
        if ( (HGRANT_i == 1'b1) && (HREADY_i == 1'b1) ) begin
          nextstate = MASTER_ADDR;
        end
        counter_t = counter;                    // keep the counter, when response is not ok
        boundary_counter_t = boundary_counter;
      end

    MASTER_ADDR :                    // Put address and control signals in the bus, and wait for HREADY high
      begin
        if ( (HGRANT_i == 1'b1) && (HREADY_i == 1'b1) ) begin
          nextstate = MASTER_DATA;
        end
        else begin                   
                if(|HRESP_i) begin               // retry, when response is not ok
                        nextstate = MASTER_REQ;
                end
        end
        counter_t = counter;
        boundary_counter_t = boundary_counter;                    // keep the counter, when response is not ok
      end

    MASTER_DATA :                    // Put HWDATA in the bus (write transfer). When HREADY goes high, latch HRDATA (read transfer)
      begin

        if ( (HGRANT_i == 1'b1) && (HREADY_i == 1'b1) ) begin
                counter_t = counter + 1'b1 ;
                if(boundary_count == 4'b0000)
                begin
                    if({1'b0, counter} == (burst_count - 1'b1)) begin
                                nextstate = MASTER_IDLE;
                                wrp_ack_o = 1'b1;
                                wrp_ack_bus_o = 1'b1;
                    end
                    else begin
                                nextstate = MASTER_DATA;
                                if(wrp_burst_cnt_i == 4'b0001)
                                    wrp_ack_o = 1'b0;
                                else
                                    wrp_ack_o = 1'b1;
                    end
                end
                else
                begin
                    if({1'b0, boundary_counter} == (boundary_count - 1'b1)) begin    
                                wrp_ack_o = 1'b1;
                                wrp_ack_bus_o = 1'b1;
                                boundary_counter_t = 3'b000 ;
                    end
                    else begin
                                wrp_ack_o = 1'b0;
                                boundary_counter_t = boundary_counter + 1'b1 ;
                    end 
                    nextstate = MASTER_IDLE;               
                end    
          end
        else begin
                if(|HRESP_i) begin               // retry, when response is not ok
                        nextstate = MASTER_REQ;
                end
                counter_t = counter;
                boundary_counter_t = boundary_counter;
          end

      end

    default :
        nextstate = MASTER_IDLE;

  endcase

end


//assign HBUSREQ_o = (state == MASTER_REQ)  ? 1'b1 : 1'b0;
assign HBUSREQ_o = (state != MASTER_IDLE)  ? 1'b1 : 1'b0;
assign HLOCK_o = (state != MASTER_IDLE)  ? 1'b1 : 1'b0;
 
endmodule
