// +FHDR ----------------------------------------------------------------
// Copyright (C) 2005, CCU SoC LAB Confidential  Proprietary
//-----------------------------------------------------------------------
// Filename         : AHB_Decoder.v
//-----------------------------------------------------------------------
// Department       : SoC LAB
// Author           : $Author: nsrta
//-----------------------------------------------------------------------
// Version          : $Revision: 1.0 $
// Last Modified On : $Date: 2006/08/23 
// Last Modified By : $Author: nsrta
//-----------------------------------------------------------------------
// Description      :
//                    AHB Decoder
// ----------------------------------------------------------------------
// Modification List:
//   o 
// -FHDR ----------------------------------------------------------------

module AHB_Decoder (
// Inputs
                   HADDR,
// Outputs
                   HSEL_RISC,
                   HSEL_ADDER
                  );

// Inputs
input  [31:0] HADDR;           // AHB address bus
// Outputs
output        HSEL_RISC;
output        HSEL_ADDER;

// Inputs
wire   [31:0] HADDR;           // AHB address bus

// Outputs
wire          HSEL_RISC;
wire          HSEL_ADDER;


assign HSEL_RISC  = (HADDR[31:16] == 16'hC080)? 1'b1 : 1'b0;
assign HSEL_ADDER = (HADDR[31:16] == 16'hC000)? 1'b1 : 1'b0;

endmodule
