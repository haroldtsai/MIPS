// +FHDR ----------------------------------------------------------------
// Copyright (C) 2005, CCU SoC LAB Confidential  Proprietary
//-----------------------------------------------------------------------
// Filename         : versatile_fpga.v
//-----------------------------------------------------------------------
// Department       : SoC LAB
// Author           : $Author: nsrta
//-----------------------------------------------------------------------
// Version          : $Revision: 1.0 $
// Last Modified On : $Date: 2006/07/23 
// Last Modified By : $Author: nsrta
//-----------------------------------------------------------------------
// Description      :
//                    RISC top module for versatile FPGA use.
// ----------------------------------------------------------------------
// Modification List:
//   o 
// -FHDR ----------------------------------------------------------------


module versatile_fpga (

        CLK_GLOBAL_IN,
        nSYSRST,
        
        //Master
        HADDRS,
        HTRANSS,
        HWRITES,
        HBURSTS,
        HPROTS,
        HSIZES,
        HRESPS,
        HREADYS,
        HDATAS,
        LTHBUSREQ,
        LTHGRANT,
        LTHLOCK,
        HMASTLOCKS,
        HSELS,
        
        //Slave
        HBUSREQM1,
        HLOCKM1,
        HGRANTM1,
        HADDRM1,
        HTRANSM1,
        HWRITEM1,
        HSIZEM1,
        HRESPM1,
        HREADYM1,
        HDATAM1,
        
        // JTAG
        D_TDI,
        D_TCK,
        D_TDO,
        D_RTCK,
        
        CLK_24MHZ_FPGA,
        ALWAYS_ONE,
        SER_PLD_DATA,
        
        LED
                
        );

input         CLK_GLOBAL_IN;       // AHB CLK_GLOBAL_IN bus clock from baseboard for M1/M2/S in synchronous mode  
input         nSYSRST;             // reset input (active low)

output [31:0] HADDRS;
output [ 1:0] HTRANSS;
output        HWRITES;
output [ 2:0] HBURSTS;
output [ 3:0] HPROTS;
output [ 1:0] HSIZES;
input  [ 1:0] HRESPS;
input         HREADYS;
inout  [31:0] HDATAS;
input         LTHBUSREQ;     // HBUSREQ from PCI master on baseboard
output        LTHGRANT;      // HGRANT to PCI master on baseboard
input         LTHLOCK;       // HLOCK from PCI master on baseboard
output        HMASTLOCKS;    // HMASTLOCK from arbiter in logic tile to S bridge in development chip
output        HSELS;         // HSEL for S bridge in development chip

input         HBUSREQM1;     // HBUSREQ from M1 bridge in development chip
input         HLOCKM1;       // HLOCK from M1 bridge in development chip
output        HGRANTM1;      // HGRANT for M1 bridge in development chip
input  [31:0] HADDRM1;
input  [ 1:0] HTRANSM1;
input         HWRITEM1;
input  [ 1:0] HSIZEM1;
output [ 1:0] HRESPM1;
inout         HREADYM1;
inout  [31:0] HDATAM1;

// JTAG
input         D_TDI;          // test data in
input         D_TCK;          // test clock
output        D_TDO;          // test data out
output        D_RTCK;         // return test clock for Multi-ICE/RVI

output [ 3:0] LED;                 // LT LEDs

input         CLK_24MHZ_FPGA;      // clock used for power up config 
input         ALWAYS_ONE;          // FPGAnWR before configuration
output        SER_PLD_DATA;        // Serial data to PLD for power up config 


/////////////////////////////////////////////////////
//©T©w for versatile
/////////////////////////////////////////////////////
assign D_TDO            = D_TDI;
assign D_RTCK           = D_TCK;

reg    [ 8:0] ShiftData;

always @(posedge CLK_24MHZ_FPGA)
begin : p_shift_reg
  if (ALWAYS_ONE == 1'b0)
    begin
      ShiftData <= {1'b0, 1'b1, 1'b0, 2'b11, 2'b10, 2'b10}; //PLD_DATA
    end
  else
    begin
      ShiftData[8:1] <= ShiftData[7:0];
    end
end // end of p_shift_reg 

assign SER_PLD_DATA = ShiftData[8];
//////////////////////////////////////////////////////
wire HGRANTM1,HSELS,HMASTLOCKS;

assign HGRANTM1 = 1'b1;
assign HSELS    = 1'b1;

//////////////////////////////////////////////////////


wire         SREQ0;
wire         SLOCK0;
wire         SGNT0;

AHBArbiter uAHBArbiter(
        .HCLK       (CLK_GLOBAL_IN),
        .nSYSRST    (nSYSRST),
        .HREADY     (HREADYS),
        .HLOCK      ({LTHLOCK,SLOCK0}),
        .HBUSREQ    ({LTHBUSREQ,SREQ0}),
        .HGRANT     ({LTHGRANT,SGNT0}),
        .HMASTLOCK  ()
       ); // end of port map AHBArbiter
       
assign HMASTLOCKS = 1'b0;


wire HSEL_RISC;
wire HSEL_ADDER;

AHB_Decoder uAHB_Decoder(
        .HADDR      (HADDRM1),
        .HSEL_RISC  (HSEL_RISC),
        .HSEL_ADDER (HSEL_ADDER)
);


wire [31:0] HWDATA_o;
wire [31:0] S_HRDATA_o;
wire S_HREADY_o;

wire HSIZEm_tmp,HSIZEs_tmp;

top topmain(
.clk_i(CLK_GLOBAL_IN),
.rst_n(nSYSRST),
//.env_set(1'b0),        // csh93, 20060405


// AMBA master interface
// ---------------- Outputs ------------------
// IO
.HBUSREQ_o(SREQ0),      // master to bus request
.HADDR_o(HADDRS),       // 32-bit system address
.HTRANS_o(HTRANSS),     // indicate type of the current transfer
.HSIZE_o({HSIZEm_tmp,HSIZES}),      // indicate size of transfer
.HBURST_o(HBURSTS),     // indicate if the transfer forms part of a burst
.HWRITE_o(HWRITES),     // 1'b1 is write transfer, 1'b0 is low transfer
.HWDATA_o(HWDATA_o),        // write data
.HPROT_o(HPROTS),       // protection control
.HLOCK_o(SLOCK0),       // 1'b1 is lock accesses

// ---------------- Inputs ------------------
// IO
//HCLK,
//HRESETn,
.HGRANT_i(SGNT0),           // indicates that bus master x is currently the highest priority master
.HREADY_i(HREADYS),             //
.HRESP_i(HRESPS),           //
.HRDATA_i(HDATAS),          // read data

// add by csh93 2006/3/15
// AMBA slave interface
// ---------------- Inputs ------------------
.S_HREADY_i(HREADYM1),
.S_HSEL_i(HSEL_RISC),
.S_HTRANS_i(HTRANSM1),
.S_HADDR_i(HADDRM1),
.S_HWRITE_i(HWRITEM1),
.S_HSIZE_i({HSIZEs_tmp,HSIZEM1}),
//.S_HBURST_i(),
.S_HWDATA_i(HDATAM1),

// ---------------- Outputs ------------------
.S_HREADY_o(S_HREADY_o),
.S_HRESP_o(HRESPM1),
.S_HRDATA_o(S_HRDATA_o),

.LED(LED)

);

//**************************************//
//             AHB Slave                //
//**************************************//

reg          ReadEnableM1;   // used to control tri-states on top level
reg          RespEnableM1;   // used to control tri-states on top level

always @(posedge CLK_GLOBAL_IN or negedge nSYSRST)
begin : p_ReadEnSeqM1
  if (!nSYSRST)
    begin
      ReadEnableM1  <= 1'b0;
      RespEnableM1  <= 1'b0;
    end
  else
    if (HREADYM1 == 1'b1)
    // start new data phase when HREADY ='1'
      if (HADDRM1[31:16] == 16'hC080)
        begin
          RespEnableM1  <= 1'b1;
          ReadEnableM1  <= ~(HWRITEM1);
        end
      else
        begin
          ReadEnableM1  <= 1'b0;
          RespEnableM1  <= 1'b0;
        end
end // p_ReadEnSeqM1


assign  HREADYM1  = (RespEnableM1 == 1'b1) ? S_HREADY_o : 1'bz;
assign  HDATAM1   = (ReadEnableM1 == 1'b1) ? S_HRDATA_o : 32'hzzzzzzzz;

//**************************************//
//             AHB Master               //
//**************************************//

reg          AHBMasterEnableS;         // '1' if a logic tile master accesses the bus during the address/control phase of the access
reg          AHBMasterDataEnableS;     // '1' if a logic tile master accesses the bus during the data phase of the access

always @(posedge CLK_GLOBAL_IN or negedge nSYSRST)
begin : p_MasterEnable
  if (!nSYSRST)
      AHBMasterEnableS <= 1'b0;
  else
    if (HREADYS == 1'b1)
      AHBMasterEnableS <= SGNT0;
end // p_MasterEnable 

always @(posedge CLK_GLOBAL_IN or negedge nSYSRST)
begin : p_MasterDataEnable
  if (!nSYSRST)
      AHBMasterDataEnableS <= 1'b0;
  else
    if (HREADYS == 1'b1)
      AHBMasterDataEnableS <= (AHBMasterEnableS & HWRITES);
end // p_MasterDataEnable 


assign HDATAS   = (AHBMasterDataEnableS == 1'b1) ? HWDATA_o : 32'hzzzzzzzz;


endmodule



