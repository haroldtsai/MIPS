module top(
                        clk_i,
                        rst_n,

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

                        // AMBA slave interface
                        // ---------------- Inputs ------------------
                        S_HREADY_i,
                        S_HSEL_i,
                        S_HTRANS_i,
                        S_HADDR_i,
                        S_HWRITE_i,
                        S_HSIZE_i,
                        //S_HBURST_i,
                        S_HWDATA_i,

                        // ---------------- Outputs ------------------
                        S_HREADY_o,
                        S_HRESP_o,
                        S_HRDATA_o,
			

                        LED
        );
        
// system signal
input                   clk_i;
input                   rst_n;

// AMBA master interface
input                   HGRANT_i;
input                   HREADY_i;
input   [1:0]           HRESP_i;
input   [31:0]          HRDATA_i;
output                  HBUSREQ_o;
output  [31:0]          HADDR_o;
output  [1:0]           HTRANS_o;
output  [2:0]           HSIZE_o;
output  [2:0]           HBURST_o;
output                  HWRITE_o;
output  [31:0]          HWDATA_o;
output  [3:0]           HPROT_o;
output                  HLOCK_o;

// AMBA slave interface
// ---------------- Inputs ------------------
input   S_HREADY_i;
input   S_HSEL_i;
input   [1:0]S_HTRANS_i;
input   [32-1:0]S_HADDR_i;
input   S_HWRITE_i;
input   [2:0]S_HSIZE_i;
//input [2:0]S_HBURST_i;
input   [32-1:0]S_HWDATA_i;

// ---------------- Outputs ------------------
output  S_HREADY_o;
output  [1:0]S_HRESP_o;
output  [32-1:0]S_HRDATA_o;

// AMBA slave interface!!!!!!!!!!!!!!!!!!!!
// ---------------- Inputs ------------------
wire    S_HREADY_i;
//wire  S_HSEL_i;
wire    [1:0]S_HTRANS_i;
wire    [32-1:0]S_HADDR_i;
wire    S_HWRITE_i;
wire    [2:0]S_HSIZE_i;
//wire  [2:0]S_HBURST_i;
wire    [32-1:0]S_HWDATA_i;

// ---------------- Outputs ------------------
wire    S_HREADY_o;
wire    [1:0]S_HRESP_o;
wire    [32-1:0]S_HRDATA_o;

// wrapper!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
wire    [31:0]          wrp_sbus_dat;
wire                    wrp_sbus_ack;
wire                    wrp_sbus_ack_bus;
wire    [31:0]          sbus_wrp_dat;
wire    [31:0]          sbus_wrp_adr;
wire                    sbus_wrp_stb;
wire                    sbus_wrp_we;
wire    [4-1:0]         sbus_wrp_sel;
wire    [3:0]           sbus_wrp_burst_cnt;

wire                    risc_dcache_flush;
//////

wire            sleep;


output  [4-1:0]LED; // 20060407
wire    [4-1:0]LED;

// by csh93 2006.10.11 for CIC nLint 
wire		rst_n_i = rst_n & (~sleep);

wire [31:0] pc_o,EX_MEMaluresult_o,instr_o,EX_MEMWMdata_o,MEMdata_o;
wire memread,memwrite,imemdone,dmemdone,request,icache_sbus_stb;
//reg dmemrw;
wire dmemrw;
wire finish;
//wire stopout;

//reg [31:0] itemp,dtemp;



wire [31:0] dtemp;

/*
always@(posedge clk_i or negedge rst_n_i)
begin
	if(!rst_n_i)
		temp <= 32'h00000000;
	else
		if(request)
			temp <= MEMdata_o;
		else temp <= temp;
end
*/

Pipe_CPU_1   cpu( 
           .clk_i(clk_i),
           //.start_i,
           .rst_i(rst_n_i),
		   
		   //icache
           .icache_ack_i(imemdone),	          
	       .icache_data_i(instr_o),
	       .icache_request_o(icache_sbus_stb),
	       
           //dcache
	       .dcache_data_i(MEMdata_o),                //從MEM讀進來的data
	       .dcache_ack_i(dmemdone),                  //跟CPU說資料進來了
	       .dcache_data_o(EX_MEMWMdata_o),           //cpu要mem紀錄的data
	       .dcache_addr_o(EX_MEMaluresult_o),        //cpu要MEM寫data的addr
	       .dcache_request_o(request),               //cpu要讀寫MEM
	       .dcache_wr_o(dmemrw),	                 //要讀或寫
		   
	       .pc_o(pc_o)
           );
/*
CPU CPU(.clk_i(clk_i),.start_i(!sleep),.reset(rst_n_i),

	.irequest(icache_sbus_stb),
	.drequest(request),                //output 要求找access mem
	.pc_o(pc_o),.EX_MEMaluresult_o(EX_MEMaluresult_o), //output   instr mem/data mem 的addr
	.instr_o(instr_o),.EX_MEMWMdata_o(EX_MEMWMdata_o), //intput instr mem 回傳記憶體內容 /output data mem要存進去的值
	.Memread_o(Memread_o),.Memwrite_o(Memwrite_o),   //output   
	.MEMdata_o(dtemp),            //input    抓data mem回傳值
	.imemdone(imemdone),.dmemdone(dmemdone),       //input    imem dmem拿到值
	.dmemrw(dmemrw),
	.finish(finish)
	);            

temp temp(

	  .clk_i(clk_i),
          .reset(rst_n_i),
          
          .mem_i(MEMdata_o),
          .mem_o(dtemp),
          
          .stop(dmemdone)
          
         );
*/
sbus sbus(
        // system signal
        .clk_i(clk_i),
        .rst_n(rst_n_i),
        
        

        .dmem_dat_i(EX_MEMWMdata_o),   //lw data 
        .dmem_adr_i(EX_MEMaluresult_o),
        .dmem_stb_i(request),
        .dmem_we_i(dmemrw),
        .dmem_burst_cnt_i(4'b0001),                                           // modify by csh93 2006/3/13
        .dmem_dat_o(MEMdata_o), //output
        .dmem_ack_o(dmemdone), //output
        // to Instruction Cache Interface
       // .imem_dat_i(risc_dcache_dat),
        .imem_adr_i(pc_o),
        .imem_stb_i(icache_sbus_stb),
    //    .imem_we_i(1'b0),
        .imem_burst_cnt_i(4'b0001),                                           // modify by csh93 2006/3/13
        .imem_dat_o(instr_o), //output
        .imem_ack_o(imemdone), //output
        
        
        
  	 // to Background Load/Store Interface
        .bg_dat_i(32'b0),
        .bg_adr_i(32'b0),
        .bg_stb_i(1'b0),
        .bg_we_i(1'b0),
        .bg_sel_i(4'b0000),
        .bg_burst_cnt_i(4'b0001),                                               // modify by csh93 2006/3/13
        .bg_dat_o(),
        .bg_ack_o(),
        // to AMBA Wrapper Interface,
        .wrp_dat_i(wrp_sbus_dat),
        .wrp_ack_i(wrp_sbus_ack),
        .wrp_ack_bus_i(wrp_sbus_ack_bus),    
        //.wrp_ack_bus_i(1'b1),                                   // modify by csh93 2006/3/13
        .wrp_dat_o(sbus_wrp_dat),
        .wrp_adr_o(sbus_wrp_adr),
        .wrp_stb_o(sbus_wrp_stb),
        .wrp_we_o(sbus_wrp_we),
        .wrp_sel_o(sbus_wrp_sel),
        .wrp_burst_cnt_o(sbus_wrp_burst_cnt)                                    // modify by csh93 2006/3/13
);

AHB_master_wrapper AHB_master_wrapper_(
        // system signal
        .clk_i(clk_i),
        //.rst_n(rst_n | sleep),
        // by csh93 2006.10.11 for CIC nLint
        .rst_n(rst_n_i),
        .Wake_Flag(sleep),                      // modify by 2006/03/21 : sleep the core - slave state

        // AMBA interface
        .HBUSREQ_o(HBUSREQ_o),                  // master to bus request
        .HADDR_o(HADDR_o),                      // 32-bit system address
        .HTRANS_o(HTRANS_o),                    // indicate type of the current transfer
        .HSIZE_o(HSIZE_o),                      // indicate size of transfer
        .HBURST_o(HBURST_o),                    // indicate if the transfer forms part of a burst
        .HWRITE_o(HWRITE_o),                    // 1'b1 is write transfer, 1'b0 is low transfer
        .HWDATA_o(HWDATA_o),                    // write data
        .HPROT_o(HPROT_o),                      // protection control
        .HLOCK_o(HLOCK_o),                      // 1'b1 is lock accesses
        .HGRANT_i(HGRANT_i),                    // indicates that bus master x is currently the highest priority master
        .HREADY_i(HREADY_i),                    //
        .HRESP_i(HRESP_i),                      //
        .HRDATA_i(HRDATA_i),                    // read data

        // system bus interface
        .wrp_dat_o(wrp_sbus_dat),
        .wrp_ack_o(wrp_sbus_ack),
        .wrp_ack_bus_o(wrp_sbus_ack_bus),       // modify by csh93 2006/3/13
        .wrp_dat_i(sbus_wrp_dat),
        .wrp_adr_i(sbus_wrp_adr),
        .wrp_stb_i(sbus_wrp_stb),
        .wrp_we_i(sbus_wrp_we),
        .wrp_sel_i(sbus_wrp_sel),
        .wrp_burst_cnt_i(sbus_wrp_burst_cnt)    // modify by csh93 2006/3/13
        
        
        );
        
AHB_slave_wrapper AHB_slave_wrapper_(
// Inputs
        .HCLK               (clk_i),
        .HRESETn            (rst_n),
        .HSEL               (S_HSEL_i),
        .HREADYIn           (S_HREADY_i),
        .HTRANS             (S_HTRANS_i),
        .HSIZE              (S_HSIZE_i[1:0]),
        .HWRITE             (S_HWRITE_i),
        .HWDATA             (S_HWDATA_i),
        .HADDR              (S_HADDR_i),
                  
// Outputs
       
        .HREADYOut          (S_HREADY_o),
        .HRESP              (S_HRESP_o),
        .HRDATA             (S_HRDATA_o),
        
        .program_finish_i   (finish),
        .sleep_o            (sleep)      


);
endmodule