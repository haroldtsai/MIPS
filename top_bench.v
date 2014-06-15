`define Mem_Size 1024*1024*64
`define half_clk_period 10000
`timescale 1ns/1ps

module top_bench;

parameter Print_Memory_ZIP_MODE = 1;

reg     clk_i;
reg     rst_n;

wire   [31:0] HADDRS;
wire   [ 1:0] HTRANSS;
wire          HWRITES;
wire   [ 2:0] HBURSTS;
wire   [ 3:0] HPROTS;
wire   [ 1:0] HSIZES;
wire   [ 1:0] HRESPS;
wire          HREADYS;
wire   [31:0] HDATAS;
//wire          LTHBUSREQ;
//wire          LTHGRANT;
//wire          LTHLOCK;
//wire          HMASTLOCKS;
//wire          HSELS;

//wire          HBUSREQM1;
//wire          HLOCKM1;
//wire          HGRANTM1;
wire   [31:0] HADDRM1;
wire   [ 1:0] HTRANSM1;
wire          HWRITEM1;
//wire   [ 1:0] HSIZEM1;
//wire   [ 1:0] HRESPM1;
wire          HREADYM1;
wire   [31:0] HDATAM1;


integer i, j;
integer counter;
integer openfile;
integer mem_dump;

wire   [31:0] HWDATA;
wire   [31:0] HRDATA;
wire   [31:0] HADDR;
reg     slave_go;

initial begin
$sdf_annotate("Pipe_CPU_1_43_CCU90_05V_wl20_g.sdf",top_design.topmain.cpu);
        clk_i = 1'b0;
        rst_n = 1'b0;  // 0329, JS Chen: change to synchronous posedge reset
        counter = -5;
        slave_go = 1'b0;
        openfile = $fopen("output.dat") | 1;
        mem_dump = $fopen("mem_dump.dat") | 1;

        #1500
        rst_n = 1'b1;  // 0329, JS Chen: change to synchronous posedge reset

        #100
        slave_go = 1'b1;
        
        #101
		memory.inst_mem[16777216]=8'b1100; //12
	    memory.inst_mem[16777220]=8'b0010; //2
		memory.inst_mem[16777224]=8'b0011; //3
		memory.inst_mem[16777228]=8'b1011; //11
		memory.inst_mem[16777232]=8'b0100; //4
		memory.inst_mem[16777236]=8'b1111; //15
		memory.inst_mem[16777240]=8'b1010; //10
		//memory.inst_mem[16777244]=8'b1111; //10
        // wake up RISC0
        AMBA_WRITE(32'hC000_0000,32'h0000_0001);
        slave_go = 1'b0;
end

initial begin
        for(i = 0; i < `Mem_Size; i = i + 1)
                memory.inst_mem[i] = 8'b0;

        $readmemb("CO_P5_test2.txt", memory.inst_mem);

end

always #`half_clk_period clk_i = !clk_i;
initial #(`half_clk_period*50000) $finish;


reg    [31:0] HADDRM1_r;
reg    [31:0] HDATAM1_r;
reg           HREADYM1_r;
reg           HWRITEM1_r;
reg    [ 1:0] HTRANSM1_r;
wire   [31:0]		MEM_test  [0:31];

task AMBA_WRITE;     ////////////////////////////////////
input [31:0] addr;
input [31:0] data;
begin
    
    HADDRM1_r = addr;
    HDATAM1_r = data;
    HREADYM1_r = 1'b1;
    HWRITEM1_r = 1'b1;
    
    @(posedge clk_i)
    #1 HTRANSM1_r = 2'b00;
    
    @(posedge clk_i)
    #1 HTRANSM1_r = 2'b10;
    
    @(posedge clk_i)
    #1 HTRANSM1_r = 2'b00;
    
    @(posedge clk_i)
    @(posedge clk_i)
    ;

end
endtask            //////////////////////////////////////

assign HADDRM1 = (slave_go)?32'hC080_0000:32'h0000_0000;
assign HDATAM1 = (slave_go)?32'h0000_0001:32'hZZZZ_ZZZZ;
assign HWRITEM1 = 1'b1;
assign HREADYM1 = (slave_go)?1'b1:1'bz;
assign HTRANSM1 = (slave_go)?2'b10:2'b00;
assign MEM_test[0] = {memory.inst_mem[16777219],memory.inst_mem[16777218], memory.inst_mem[16777217], memory.inst_mem[16777216]};
assign MEM_test[1] = {memory.inst_mem[16777223],memory.inst_mem[16777222], memory.inst_mem[16777221], memory.inst_mem[16777220]};
assign MEM_test[2] = {memory.inst_mem[16777227],memory.inst_mem[16777226], memory.inst_mem[16777225], memory.inst_mem[16777224]};
assign MEM_test[3] = {memory.inst_mem[16777231],memory.inst_mem[16777230], memory.inst_mem[16777229], memory.inst_mem[16777228]};
assign MEM_test[4] = {memory.inst_mem[16777235],memory.inst_mem[16777234], memory.inst_mem[16777233], memory.inst_mem[16777232]};
assign MEM_test[5] = {memory.inst_mem[16777239],memory.inst_mem[16777238], memory.inst_mem[16777237], memory.inst_mem[16777236]};
assign MEM_test[6] = {memory.inst_mem[16777243],memory.inst_mem[16777242], memory.inst_mem[16777241], memory.inst_mem[16777240]};
assign MEM_test[7] = {memory.inst_mem[16777247],memory.inst_mem[16777246], memory.inst_mem[16777245], memory.inst_mem[16777244]};
assign MEM_test[8] = {memory.inst_mem[16777251],memory.inst_mem[16777250], memory.inst_mem[16777249], memory.inst_mem[16777248]};
assign MEM_test[9] = {memory.inst_mem[16777255],memory.inst_mem[16777254], memory.inst_mem[16777253], memory.inst_mem[16777252]};
assign MEM_test[10] = {memory.inst_mem[16777259],memory.inst_mem[16777258], memory.inst_mem[16777257], memory.inst_mem[16777256]};
assign MEM_test[11] = {memory.inst_mem[16777263],memory.inst_mem[16777262], memory.inst_mem[16777261], memory.inst_mem[16777260]};
assign MEM_test[12] = {memory.inst_mem[16777267],memory.inst_mem[16777266], memory.inst_mem[16777265], memory.inst_mem[16777264]};
assign MEM_test[13] = {memory.inst_mem[16777271],memory.inst_mem[16777270], memory.inst_mem[16777269], memory.inst_mem[16777268]};
assign MEM_test[14] = {memory.inst_mem[16777275],memory.inst_mem[16777274], memory.inst_mem[16777273], memory.inst_mem[16777272]};
assign MEM_test[15] = {memory.inst_mem[16777279],memory.inst_mem[16777278], memory.inst_mem[16777277], memory.inst_mem[16777276]};

always@(posedge clk_i) begin
        if( HADDRS==32'hC080_0000 && HDATAS==32'h0000_0002)
            slave_go <= 0;
		
    //$display("PC = %d", top_design.topmain.cpu.PC.pc_out_o);
    /*$display("Data Memory = %d, %d, %d, %d, %d, %d, %d, %d",top_design.topmain.cpu.DM.memory[0], top_design.topmain.cpu.DM.memory[1], top_design.topmain.cpu.DM.memory[2], top_design.topmain.cpu.DM.memory[3], top_design.topmain.cpu.DM.memory[4], top_design.topmain.cpu.DM.memory[5], top_design.topmain.cpu.DM.memory[6], top_design.topmain.cpu.DM.memory[7]);
    //$display("Data Memory = %d, %d, %d, %d, %d, %d, %d, %d",top_design.topmain.cpu.DM.memory[8], top_design.topmain.cpu.DM.memory[9], top_design.topmain.cpu.DM.memory[10], top_design.topmain.cpu.DM.memory[11], top_design.topmain.cpu.DM.memory[12], top_design.topmain.cpu.DM.memory[13], top_design.topmain.cpu.DM.memory[14], top_design.topmain.cpu.DM.memory[15]);
    //$display("Data Memory = %d, %d, %d, %d, %d, %d, %d, %d",top_design.topmain.cpu.DM.memory[16], top_design.topmain.cpu.DM.memory[17], top_design.topmain.cpu.DM.memory[18], top_design.topmain.cpu.DM.memory[19], top_design.topmain.cpu.DM.memory[20], top_design.topmain.cpu.DM.memory[21], top_design.topmain.cpu.DM.memory[22], top_design.topmain.cpu.DM.memory[23]);
    //$display("Data Memory = %d, %d, %d, %d, %d, %d, %d, %d",top_design.topmain.cpu.DM.memory[24], top_design.topmain.cpu.DM.memory[25], top_design.topmain.cpu.DM.memory[26], top_design.topmain.cpu.DM.memory[27], top_design.topmain.cpu.DM.memory[28], top_design.topmain.cpu.DM.memory[29], top_design.topmain.cpu.DM.memory[30], top_design.topmain.cpu.DM.memory[31]);*/
    $display("Data Memory [0]=%d, [1]=%d, [2]=%d, [3]=%d, [4]=%d, [5]=%d, [6]=%d, [7]=%d", MEM_test[0], MEM_test[1], MEM_test[2], MEM_test[3], MEM_test[4], MEM_test[5], MEM_test[6], MEM_test[7]);
	$display("Data Memory [8]=%d, [9]=%d, [a]=%d, [b]=%d, [c]=%d, [d]=%d, [e]=%d, [f]=%d", MEM_test[8], MEM_test[9], MEM_test[10], MEM_test[11], MEM_test[12], MEM_test[13], MEM_test[14], MEM_test[15]);
	//$display("Registers");
    //$display("R0 = %d, R1 = %d, R2 = %d, R3 = %d, R4 = %d, R5 = %d, R6 = %d, R7 = %d", top_design.topmain.cpu.RF.Reg_File[ 0], top_design.topmain.cpu.RF.Reg_File[ 1], top_design.topmain.cpu.RF.Reg_File[ 2], top_design.topmain.cpu.RF.Reg_File[ 3], top_design.topmain.cpu.RF.Reg_File[ 4], top_design.topmain.cpu.RF.Reg_File[ 5], top_design.topmain.cpu.RF.Reg_File[ 6], top_design.topmain.cpu.RF.Reg_File[ 7]);
    //$display("R8 = %d, R9 = %d, R10 =%d, R11 =%d, R12 =%d, R13 =%d, R14 =%d, R15 =%d", top_design.topmain.cpu.RF.Reg_File[ 8], top_design.topmain.cpu.RF.Reg_File[ 9], top_design.topmain.cpu.RF.Reg_File[10], top_design.topmain.cpu.RF.Reg_File[11], top_design.topmain.cpu.RF.Reg_File[12], top_design.topmain.cpu.RF.Reg_File[13], top_design.topmain.cpu.RF.Reg_File[14], top_design.topmain.cpu.RF.Reg_File[15]);
    //$display("R16 =%d, R17 =%d, R18 =%d, R19 =%d, R20 =%d, R21 =%d, R22 =%d, R23 =%d", top_design.topmain.cpu.RF.Reg_File[16], top_design.topmain.cpu.RF.Reg_File[17], top_design.topmain.cpu.RF.Reg_File[18], top_design.topmain.cpu.RF.Reg_File[19], top_design.topmain.cpu.RF.Reg_File[20], top_design.topmain.cpu.RF.Reg_File[21], top_design.topmain.cpu.RF.Reg_File[22], top_design.topmain.cpu.RF.Reg_File[23]);
    //$display("R24 =%d, R25 =%d, R26 =%d, R27 =%d, R28 =%d, R29 =%d, R30 =%d, R31 =%d", top_design.topmain.cpu.RF.Reg_File[24], top_design.topmain.cpu.RF.Reg_File[25], top_design.topmain.cpu.RF.Reg_File[26], top_design.topmain.cpu.RF.Reg_File[27], top_design.topmain.cpu.RF.Reg_File[28], top_design.topmain.cpu.RF.Reg_File[29], top_design.topmain.cpu.RF.Reg_File[30], top_design.topmain.cpu.RF.Reg_File[31]);
	//$display("hi = %u,lo = %u",top_design.topmain.cpu.RF.Reg_hi,top_design.topmain.cpu.RF.Reg_lo);

	
			
			
end



versatile_fpga top_design(

        .CLK_GLOBAL_IN(clk_i),
        .nSYSRST(rst_n),
        
        //Master
        .HADDRS(HADDRS),
        .HTRANSS(HTRANSS),
        .HWRITES(HWRITES),
        .HBURSTS(HBURSTS),
        .HPROTS(HPROTS),
        .HSIZES(HSIZES),
        .HRESPS(HRESPS),
        .HREADYS(HREADYS),
        .HDATAS(HDATAS),
        .LTHBUSREQ(1'b0),
        .LTHGRANT(),
        .LTHLOCK(),
        .HMASTLOCKS(),
        .HSELS(),
        
        //Slave
        .HBUSREQM1(),
        .HLOCKM1(),
        .HGRANTM1(),
        .HADDRM1(HADDRM1),
        .HTRANSM1(HTRANSM1),
        .HWRITEM1(HWRITEM1),
        .HSIZEM1(),
        .HRESPM1(),
        .HREADYM1(HREADYM1),
        .HDATAM1(HDATAM1),
        
        // JTAG
        .D_TDI(),
        .D_TCK(),
        .D_TDO(),
        .D_RTCK(),
        
        .CLK_24MHZ_FPGA(),
        .ALWAYS_ONE(),
        .SER_PLD_DATA(),
        
        .LED()
                
        );


assign HADDR = (HADDRS[31:16]==16'hC080)?32'hzzzz_zzzz:(HADDRS-32'h0400_0000);
assign HDATAS = (HWRITES)?32'hzzzz_zzzz:HRDATA;
assign HWDATA = HDATAS;

assign HBUSREQ = 1'b1;

AMBA_behavior memory(
                         .clk_i(clk_i),
                         .rst_n(rst_n),

                         .HBUSREQ_i(HBUSREQ),
                         .HADDR_i(HADDR),
                         .HTRANS_i(HTRANSS),
                         .HSIZE_i({1'b0,HSIZES}),
                         .HBUrst_n(HBURSTS),
                         .HWRITE_i(HWRITES),
                         .HWDATA_i(HWDATA),
                         .HPROT_i(HPROTS),
                         .HLOCK_i(),
                         .HGRANT_o(),
                         .HREADY_o(HREADYS),
                         .HRESP_o(HRESPS),
                         .HRDATA_o(HRDATA)
);




endmodule
