module AHB_slave_wrapper (
// Inputs
                  HCLK,
                  HRESETn,
                  HSEL,
                  HREADYIn,
                  HTRANS,
                  HSIZE,
                  HWRITE,
                  HWDATA,
                  HADDR,
                  
// Outputs
                  HREADYOut,
                  HRESP,
                  HRDATA,
                  
                  program_finish_i,
                  sleep_o                  
                  );

// Inputs
input         HCLK;      // system bus clock
input         HRESETn;   // reset input (active low)
input         HSEL;      // AHB peripheral select
input         HREADYIn;  // AHB ready input
input   [1:0] HTRANS;    // AHB transfer type
input   [1:0] HSIZE;     // AHB hsize
input         HWRITE;    // AHB hwrite
input  [31:0] HWDATA;    // AHB write data bus
input  [31:0] HADDR;     // AHB address bus

input         program_finish_i;

// Outputs
output        HREADYOut; // AHB ready output to S->M mux
output  [1:0] HRESP;     // AHB response
output [31:0] HRDATA;    // AHB read data bus

output        sleep_o;

// Inputs
wire          HCLK;      // system bus clock
wire          HRESETn;   // reset input (active low)
wire          HSEL;      // AHB peripheral select
wire          HREADYIn;  // AHB ready input
wire    [1:0] HTRANS;    // AHB transfer type
wire    [1:0] HSIZE;     // AHB hsize
wire          HWRITE;    // AHB hwrite
wire   [31:0] HWDATA;    // AHB write data bus
wire   [31:0] HADDR;     // AHB address bus

// Outputs
wire          HREADYOut; // AHB ready output to S->M mux
wire    [1:0] HRESP;     // AHB response
wire   [31:0] HRDATA;    // AHB read data bus

reg           sleep_o;

// -----------------------------------------------------------------------------
// Constant declarations
// -----------------------------------------------------------------------------
parameter ST_IDLE    = 2'b00;
parameter ST_READ    = 2'b01;
parameter ST_WRITE   = 2'b10;

// HTRANS transfer type signal encoding
parameter TRN_IDLE   = 2'b00;
parameter TRN_BUSY   = 2'b01;
parameter TRN_NONSEQ = 2'b10;
parameter TRN_SEQ    = 2'b11;

// HRESP transfer response signal encoding
parameter RSP_OKAY   = 2'b00;
parameter RSP_ERROR  = 2'b01;
parameter RSP_RETRY  = 2'b10;
parameter RSP_SPLIT  = 2'b11;

// -----------------------------------------------------------------------------
// Wire declarations
// -----------------------------------------------------------------------------
wire       Valid;
// Module is selected with valid transfer

// -----------------------------------------------------------------------------
// Register declarations
// -----------------------------------------------------------------------------
reg  [1:0] NextState;
// State machine

reg  [1:0] CurrentState;
// Current state


// -----------------------------------------------------------------------------
// Valid transfer detection
// The slave must only respond to a valid transfer, so this must be detected.
// Valid AHB transfers only take place when a non-sequential or sequential
// transfer is shown on HTRANS - an idle or busy transfer should be ignored.
// -----------------------------------------------------------------------------
assign Valid            = ((HSEL == 1'b1) && (HREADYIn == 1'b1) &&
                           ((HTRANS == TRN_NONSEQ) || (HTRANS == TRN_SEQ))) ?
                          1'b1 : 1'b0;

// -----------------------------------------------------------------------------
// Next state logic for APB state machine
// Generates next state from CurrentState and AHB inputs.
// -----------------------------------------------------------------------------
always @(CurrentState or Valid or HWRITE)
begin : p_NextStateComb
  case (CurrentState)

    // Idle state
    ST_IDLE :
      if (Valid == 1'b1)
        if (HWRITE == 1'b1)
          NextState = ST_WRITE;
        else
          NextState = ST_READ;
      else
        NextState   = ST_IDLE;

    // second read cycle
    ST_READ :
      if (Valid == 1'b1)
        if (HWRITE == 1'b1)
          NextState = ST_WRITE;
        else
          NextState = ST_READ;
      else
        NextState   = ST_IDLE;

    // second write cycle
    ST_WRITE :
      if (Valid == 1'b1)
        if (HWRITE == 1'b1)
          NextState = ST_WRITE;
        else
          NextState = ST_READ;
      else
        NextState   = ST_IDLE;

    // Return to idle on FSM error
    default :
       NextState    = ST_IDLE;

  endcase
end // p_NextStateComb


// -----------------------------------------------------------------------------
// State machine
// Changes state on rising edge of HCLK.
// -----------------------------------------------------------------------------
always @(negedge HRESETn or posedge HCLK)
begin : p_CurrentStSeq
  if (HRESETn == 1'b0)
    CurrentState <= ST_IDLE;
  else
    CurrentState <= NextState;
end // p_CurrentStSeq

// -----------------------------------------------------------------------------
// RISC control
// -----------------------------------------------------------------------------

reg [7:0]delay_counter;
reg counter_go;
/*
reg  finish_t;

always @(posedge HCLK)
begin
	if(program_finish_i)
		finish_t = 1'b1;
end
*/
wire    rst_n_i = HRESETn & (~sleep_o);
//wire    rst_n_i = (HRESETn & (~sleep_o))| finish_t;

always @(negedge rst_n_i or posedge HCLK)
begin
        if(!rst_n_i)
            counter_go <= 1'b0;
        else
        begin
            if(program_finish_i)
                counter_go <= 1'b1;
            else
                counter_go <= counter_go;
        end
end

always @(negedge rst_n_i or posedge HCLK)
begin
        if(!rst_n_i)
            delay_counter <= 8'h00;
        else
        begin
            if(counter_go)
                delay_counter <= delay_counter + 1'b1;
            else
                delay_counter <= delay_counter;
        end
end
        


always @(negedge HRESETn or posedge HCLK)
begin
        if(!HRESETn)
        begin
            sleep_o <= 1'b1;        
        end
        else 
        begin
            if(delay_counter==8'h80)
                sleep_o <= 1'b1;
            else if(CurrentState == ST_WRITE && HWDATA == 32'h0000_0001) 
            begin
                sleep_o <= 1'b0;
            end
            else
                sleep_o <= sleep_o;
        end

end


// -----------------------------------------------------------------------------
// AHB output drivers
// -----------------------------------------------------------------------------
assign HRDATA          = 32'h0;
assign HRESP           = RSP_OKAY;
assign HREADYOut       = 1'b1;

endmodule

// --================================== End ==================================--
