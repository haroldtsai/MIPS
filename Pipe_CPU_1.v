//Subject:     Training with AMBA
//--------------------------------------------------------------------------------
//Version:     n
//--------------------------------------------------------------------------------
//Writer:      9817262
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: Orz
//--------------------------------------------------------------------------------
module Pipe_CPU_1(
        clk_i,
		rst_i,
		icache_ack_i,
		icache_data_i,
		icache_request_o,
 		  
		dcache_data_i,
		dcache_ack_i,
		dcache_data_o,
		dcache_addr_o,
		dcache_request_o,
		dcache_wr_o,
	    pc_o
    );
reg [31:0] counterr = 1;     
/****************************************
I/O ports
****************************************/
input           rst_i;
input           clk_i;
input           icache_ack_i;
input   [31:0]  icache_data_i;
output reg      icache_request_o;

input  [31:0]   dcache_data_i;
input           dcache_ack_i;
output [31:0]   dcache_data_o;
output [31:0]   dcache_addr_o;
output          dcache_request_o;
output          dcache_wr_o;
output [31:0]   pc_o;

/****************************************
Internal signal
****************************************/
//module wire - EX
wire [32-1:0] EX_mux_out;
wire [4-1:0]  EX_ALUctrl_out;
wire          EX_ALUZero;
wire [32-1:0] EX_ALUrelt;
wire [32-1:0] EX_mux1_out;
wire [5-1:0]  EX_mux2_out;
wire [5-1:0]  EX_mux2_out2;
wire [32-1:0] EX_shift_in;
wire [32-1:0] EX_shift_out;
wire [32-1:0] EX_add_out;
//module wire - MEM
wire [32-1:0] MEM_readdata;
wire [5-1:0]  MEM_mux;


/**** IF stage ****/
wire  [32-1:0]  PC_add_four;
wire  [32-1:0]  IF_PC_out;
wire  [32-1:0]  IF_PC_in;
wire  [32-1:0]  IF_PC_in2;
wire  [32-1:0]  IF_PC_in3;
wire  [32-1:0]  IF_PC_in4;
wire  [32-1:0]  IF_instr_out;

wire            PCWrite;
wire 		    IF_ID_remain;
wire 		    IF_ID_remain2;
wire            IF_Flush;   //NEW!!
wire  [64-1:0]  IF_decide;  //NEW!!
wire  [64-1:0]  IF_ID_in;
reg   [32-1:0]  idata_temp;   
 
assign IF_ID_in = {
		PC_add_four,
		icache_data_i
		//idata_temp
	};

/**** ID stage ****/
wire           ID_Flush;
wire [165-1:0] ID_decide;
wire [64-1:0]  IF_ID_out;
wire [165-1:0] ID_EX_in;
wire [32-1:0]  ID_instr;
wire [32-1:0]  ID_pc;

wire [32-1:0]  ID_Read_data_1;
wire [32-1:0]  ID_Read_data_1_mux;
wire [32-1:0]  ID_Read_data_2;
wire [32-1:0]  ID_Signextend;

/******** signal ********/
wire         ID_RegWrite;
wire         ID_MemtoReg;
wire         ID_branch;
wire         ID_MemRead;
wire         ID_Memwrite;
wire [4-1:0] ID_ALUOp;
wire         ID_RegDst;
wire         ID_ALUSrc;
wire         ID_jr;
wire         ID_j;
wire         ID_jal;
wire         ID_MemRead_H;
wire         ID_MemRead_B;
wire         ID_MemWrite_H;
wire         ID_MemWrite_B;
wire         ID_RegWrite_mult;
wire         ID_mfhi;
wire         ID_mflo;
wire         ID_div;
wire         ID_swm;
wire         ID_ACD_stall;
wire [32-1:0]ID_ACD_base;
wire         EX_stall_complete;
wire [32-1:0]ID_base_or_signedextend;
wire [5-1:0] ID_src2_or_target;
wire [5-1:0] ID_ACD_src2;
wire         ID_ACD_memerite;
wire         ID_ACD_regwrite;
wire         ID_ACD_DECODER_memwrite;
wire         ID_ACD_DECODER_regwrite;
wire         mux_lsm_sel;        //sj
wire [32-1:0] data_base_o;       //sj
wire [32-1:0] ACD_base_select;
wire [32-1:0] ACD_base_final;    //sj    
wire [2-1:0]  mlsfording_select;
wire [21-1:0] addrcode_lsm;      //sj
wire [21-1:0] addrcode_ACD_i;    //sj
wire [21-1:0] addrcode_ACD_o;    //sj
wire          memwrite_mls;
wire          regwrite_mls;
assign {ID_pc,ID_instr} = IF_ID_out;
//assign ID_ACD_DECODER_memwrite = ID_ACD_memerite & ID_Memwrite;
//assign ID_ACD_DECODER_regwrite = ID_ACD_regwrite & ID_RegWrite;
assign ID_ACD_DECODER_memwrite = ID_Memwrite;
assign ID_ACD_DECODER_regwrite = ID_RegWrite;
assign ID_EX_in ={
        ID_swm,
        ID_div,
        ID_RegWrite_mult,
        ID_MemWrite_H,    //1
		ID_MemWrite_B,    //1
        ID_MemRead_H,     //1
		ID_MemRead_B,     //1
        ID_jal,           //1
        ID_j,             //1
        ID_jr,            //1
		ID_ACD_DECODER_regwrite | regwrite_mls,    //1
        ID_MemtoReg,                //1
        ID_branch,                  //1
        ID_MemRead,                 //1
        ID_ACD_DECODER_memwrite | memwrite_mls,    //1
		ID_RegDst,                  //1
        ID_ALUOp,                   //4            
		ID_ALUSrc,                  //1
		ID_pc,                      //32
		ID_Read_data_1_mux,         //32  because of load store multiple we should choose src1 or 0; 
		ID_Read_data_2,             //32
		ID_base_or_signedextend,    //32
		ID_instr[25:21],            //5   rs
		ID_src2_or_target,          //5   rt
		ID_instr[15:11],            //5    
		EX_stall_complete
    };

//control signal
//no ID signal

/**** EX stage ****/
wire             EX_Flush;        //NEW!!
wire  [209-1:0]  EX_decide;       //NEW!!
wire  [165-1:0]  ID_EX_out;          ////////////////////////////////???
wire  [209-1:0]  EX_MEM_in;       //!!!

wire  [32-1:0] EX_pc;
wire  [32-1:0] EX_ALUcontrol;
wire  [32-1:0] EX_src1;
wire  [32-1:0] EX_src2;
wire  [32-1:0] EX_Write_MEM_Data;   //NEW!!

wire  [32-1:0] ALU_src_1;           //NEW!!
wire  [32-1:0] ALU_src_2;           //NEW!!
//wire  [32-1:0] EX_PC;
wire  [2-1:0]  Forward_to_A;        //NEW!!
wire  [2-1:0]  Forward_to_B;        //NEW!!

wire  [5-1:0]  EX_rs;               //NEW!!
wire  [5-1:0]  EX_rt;
wire  [5-1:0]  EX_rd;
wire  [32-1:0] EX_stall_counter;
wire  [21-1:0] EX_L_S_code;  
//control signal
wire            EX_swm;
wire            EX_jr;
wire  [2-1:0]   EX_WB;
wire  [3-1:0]   EX_M;
wire            EX_RegDst;
wire  [4-1:0]   EX_ALUop;
wire            EX_ALUSrc;
wire            EX_j;
wire            EX_jal;
wire            EX_MemRead_H;
wire            EX_MemRead_B;
wire            EX_MemWrite_H;
wire            EX_MemWrite_B; 
wire            EX_RegWrite_mult;
wire  [64-1:0]  EX_ALU_mult_data;
wire            ALU_stall_o;
wire  [32-1:0]  EX_Read_data_1_mux;
wire            EX_EX_stall_complete;
wire            EX_div;
wire            ALU_stall;
wire  [64-1:0]  div_pipe_a_in;
wire  [32-1:0]  div_pipe_b_in;
wire  [64-1:0]  div_pipe_a_out;
wire  [32-1:0]  div_pipe_b_out;
assign IF_ID_remain2  = IF_ID_remain | ALU_stall_o;  
assign{  
	    EX_swm,
		EX_div,          //1
		EX_RegWrite_mult,//1
		EX_MemWrite_H,   //1
        EX_MemWrite_B,   //1
		EX_MemRead_H,    //1
        EX_MemRead_B,    //1
		EX_jal,          //1
		EX_j,            //1
		EX_jr,           //1
		EX_WB  ,         //2 
        EX_M   ,         //3
		EX_RegDst ,      //1
		EX_ALUop ,       //4
        EX_ALUSrc,       //1
		EX_pc,           //32
		EX_src1,         //32
		EX_src2 ,        //32
		EX_ALUcontrol,   //32  signed extension
		EX_rs,           //5
		EX_rt ,          //5
		EX_rd,           //5
		EX_EX_stall_complete//1
    } = ID_EX_out;        
	                    //+--------
						//161
assign  EX_MEM_in = {
		EX_RegWrite_mult,
		EX_MemWrite_H, //1
        EX_MemWrite_B, //1
		EX_MemRead_H,  //1
        EX_MemRead_B,  //1
		EX_jal ,       //1
		EX_WB  ,       //2 
		EX_M   ,       //3
        EX_add_out ,   //32
	    EX_ALUZero,    //1
		EX_ALUrelt,    //32
		EX_Write_MEM_Data,       //32 CHANGE
		EX_mux2_out2,            // 5
		EX_pc,
		EX_ALU_mult_data
    };                 
/**** MEM stage ****/


wire [209-1:0] EX_MEM_out;
wire [169-1:0] MEM_WB_in;
wire [32-1:0]  MEM_add;
wire [32-1:0]  MEM_writedata;
wire [32-1:0]  MEM_addr;
wire [32-1:0]  MEM_addr_jal;
wire [32-1:0]  MEM_PC;
wire [5-1:0]   MEM_writereg;
 

//control signal
wire          MEM_branch;
wire [2-1:0]  MEM__WB;
wire          MEM_read;
wire          MEM_zero;
wire          MEM_write;
wire          MEM_jal;
wire          MEM_MemRead_H;
wire          MEM_MemRead_B;
wire          MEM_MemWrite_H;
wire          MEM_MemWrite_B;
wire          MEM_PCSrc;
wire          MEM_RegWrite_mult;
wire [64-1:0] MEM_ALU_mult_data;
wire [21-1:0] MEM_L_S_code;
reg  [32-1:0] MEM_data_temp;
reg  [32-1:0] MEM_data_temp2;
reg  [32-1:0] MEM_writedata_TEMP;
assign MEM_PCSrc = MEM_zero & MEM_branch;
assign { 
        MEM_RegWrite_mult,
		MEM_MemWrite_H,
        MEM_MemWrite_B,
		MEM_MemRead_H,
		MEM_MemRead_B,
		MEM_jal,
		MEM__WB,         // 2
        MEM_branch,      // 1
	    MEM_read,        // 1
		MEM_write,       // 1
	    MEM_add,         //32
		MEM_zero,        // 1
		MEM_addr,        //32
		MEM_writedata,   //32
		MEM_writereg,    // 5
        MEM_PC,		     //32
        MEM_ALU_mult_data
		//MEM_L_S_code		 
	} = EX_MEM_out ;  //+--------	
		                 //139
assign MEM_WB_in = {
		MEM_RegWrite_mult,
		MEM_jal,
        MEM__WB,           // 2
		//MEM_readdata,
		//MEM_addr,
        MEM_data_temp2,    //32 
        dcache_addr_o,     //32
        MEM_writereg,      // 5
        MEM_PC,            //32
        MEM_ALU_mult_data  //64			 
    };                     //+-----
	   
	   

/*
assign dcache_addr_o    = MEM_addr;                  ok
assign dcache_wr_o      = (MEM_read==1)? 0: 1;       no
assign dcache_data_o    = MEM_writedata;             no
assign dcache_request_o = MEM_read | MEM_write;      no
assign MEM_readdata     = dcache_data_i;             ok
*/
	   
/**** WB stage ****/

wire  [169-1:0]  MEM_WB_out;

wire  [32-1:0]  WB_memdata;
wire  [32-1:0]  WB_aludata;
wire  [32-1:0]  WB_WriteRegData;
wire  [32-1:0]  WB_WriteRegPcData;
wire  [32-1:0]  WB_PC;
wire  [5-1:0]   WB_WriteReg;
//control signal

wire            WB_MemtoReg;
wire            RegWrite;
wire            WB_jal;
wire            WB_RegWrite_mult;  
wire  [64-1:0]  WB_ALU_mult_data;

assign {
        WB_RegWrite_mult,
        WB_jal,
		RegWrite,        //1
		WB_MemtoReg,     //1
		WB_memdata,      //32
		WB_aludata,      //32
		WB_WriteReg,     //5
		WB_PC,           //32
		WB_ALU_mult_data //64
	} =MEM_WB_out;
		
assign dcache_addr_o    = MEM_addr;
assign dcache_wr_o      = (MEM_read==1)?0: ( (MEM_MemRead_B==1)? 0:((MEM_MemRead_H==1)?0:1)  );
assign dcache_data_o    = MEM_writedata_TEMP;
assign dcache_request_o = MEM_read | MEM_write | MEM_MemWrite_H | MEM_MemWrite_B | MEM_MemRead_H | MEM_MemRead_B;
assign MEM_readdata     = dcache_data_i;
assign pc_o             = IF_PC_out[31:0];

/****************************************
Instnatiate modules
****************************************/
//Instantiate the components in IF stage

always @(posedge  clk_i)
begin
	if(~rst_i) icache_request_o = 0;
	else       icache_request_o = 1;
	if(dcache_ack_i)MEM_data_temp = dcache_data_i;  	       	
	else if(MEM_MemRead_H)MEM_data_temp2 = MEM_data_temp[15:0];
	else if(MEM_MemRead_B)MEM_data_temp2 = MEM_data_temp[7:0];
	else MEM_data_temp2 = MEM_data_temp;
	if(MEM_MemWrite_B)  MEM_writedata_TEMP = MEM_writedata[7:0];
   	else if(MEM_MemWrite_H) MEM_writedata_TEMP = MEM_writedata[15:0];
	else MEM_writedata_TEMP = MEM_writedata;
			       	
end

/*always @(negedge icache_ack_i)begin
        if(~rst_i)idata_temp<=0;
		else begin
		  counterr <= counterr+1;
		  if(icache_data_i==0)idata_temp = 2;
		  else idata_temp<= icache_data_i;
		end

end*/

ProgramCounter PC(
	    .clk_i(clk_i),
	    .rst_i(rst_i),
	    .pc_in_i(IF_PC_in4),
	    .pc_out_o(IF_PC_out),
	    .pcwrite(PCWrite & icache_ack_i)
    );


MUX_2to1 #(.size(32)) Mux1(
        .data0_i(PC_add_four),
		.data1_i(MEM_add),          //in
		.select_i(MEM_PCSrc),       //in
        .data_o(IF_PC_in)           //out
    );
	
MUX_2to1 #(.size(32)) Mux1_jr(                
		.data0_i(IF_PC_in),     //src1
		.data1_i(ALU_src_1),    //src2
	    .select_i(EX_jr),       //ctr
        .data_o(IF_PC_in2)      //out
    );

MUX_2to1 #(.size(32)) Mux1_j(                
		.data0_i(IF_PC_in2),       //src1
		.data1_i(EX_ALUcontrol),   //src2
	    .select_i(EX_j),           //ctr
        .data_o(IF_PC_in3)         //out
    );
 
MUX_2to1 #(.size(32)) Mux1_jal(                
		.data0_i(IF_PC_in3),          //src1
		.data1_i(EX_ALUcontrol),      //src2
	    .select_i(EX_jal),            //ctr
        .data_o(IF_PC_in4)            //out
    );
    

Adder Add_pc(
		.src1_i(IF_PC_out),
		.src2_i(4),
		.sum_o(PC_add_four)
    );
	
MUX_2to1 #(.size(64)) IF_ID_FLUSH(
	    .data0_i(IF_ID_in),          //src1
	    .data1_i(64'b0),             //src2
	    .select_i(IF_Flush),         //ctr
	    .data_o(IF_decide)           //out
	);		
	
Pipe_Reg #(.size(64)) IF_ID(
		.rst_i(rst_i),
		.clk_i(clk_i),                       //N is the total length of input/output
		.data_i(IF_decide),
		.remain(IF_ID_remain | ~icache_ack_i),
		.data_o(IF_ID_out)
    );
 
Hazard_detection_unit  H_D_U(
        .ALU_stall(ALU_stall_o),
		.SWM_stall_i(ID_ACD_stall),
        .EX_jal(EX_jal),
        .EX_j(EX_j),
		.EX_jr(EX_jr),
		.PCSrc(MEM_PCSrc),
		.ID_EX_MemRead(EX_M[1]),       //detect if read mem or not(Yes , if load)
		.loaded_reg(EX_rt),
		.use_rs(ID_instr[25:21]),
		.use_rt(ID_instr[20:16]),
		.PCWrite(PCWrite),
		.IF_ID_remain(IF_ID_remain),   //output
		.IF_Flush(IF_Flush),           //output
		.ID_Flush(ID_Flush),           //output
		.EX_Flush(EX_Flush)		       //output
    );

//Instantiate the components in ID stage

Reg_File RF(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.RSaddr_i(ID_instr[25:21]),
		.RTaddr_i(ID_src2_or_target),
		.RDaddr_mf_i(ID_instr[15:11]),
		.mfhi_i(ID_mfhi),                   //control
		.mflo_i(ID_mflo),                   //control
		.RDaddr_i(WB_WriteReg),
		.RDdata_i(WB_WriteRegPcData),
		.RegWrite_i(RegWrite),
		.RegWrite_mult_i(WB_RegWrite_mult),         //  control
		.RegWrite_mult_MEM_i(MEM_RegWrite_mult),    //  control
		.RegWrite_mult_EX_i(EX_RegWrite_mult),      //  control
		.mult_data_WB_i(WB_ALU_mult_data),			
		.mult_data_MEM_i(MEM_ALU_mult_data),
		.mult_data_EX_i(EX_ALU_mult_data),
		.RSdata_o(ID_Read_data_1),                  //RS
		.RTdata_o(ID_Read_data_2)                   //RT
    );

mlsfording mlsfording(
        .EX_RegWrite_i(EX_WB[1]),
        .MEM_RegWrite_i(MEM__WB[1]),
	    .WB_RegWrite_i(RegWrite),
		.ID_base_i(ID_instr[25:21]),
		.EX_target_i(EX_mux2_out),
		.MEM_target_i(MEM_writereg),
		.WB_target_i(WB_WriteReg),
		.select_o(mlsfording_select)
    );	


MUX_4to1 #(.size(32)) base_select(
        .data0_i(ID_Read_data_1),
		.data1_i(EX_ALUrelt),               //in
	    .data2_i(MEM_addr),                 //in
        .data3_i(WB_WriteRegPcData),        //in
		.select_i(mlsfording_select),
		.data_o(ACD_base_select)
    );
	
MUX_2to1 #(.size(5)) src2_selsct(
        .data0_i(ID_instr[20:16]),
		.data1_i(ID_ACD_src2),                     //in
	    .select_i(ID_swm),                         //in
        .data_o(ID_src2_or_target)                 //out
    );	
 
MUX_2to1 #(.size(32)) load_store_mult(
		.data0_i(ID_Read_data_1),          //if ID_ACD_stall == 0
		.data1_i(32'b0),                   //if ID_ACD_stall == 1
		.select_i(ID_swm),
		.data_o(ID_Read_data_1_mux)
	); 
 
MUX_2to1 #(.size(32)) load_store_mult2(
		.data0_i(ALU_src_1),          //if ID_ACD_stall == 0
		.data1_i(32'b0),              //if ID_ACD_stall == 1
		.select_i(EX_swm),
		.data_o(EX_Read_data_1_mux)
	);  		  
   
/*AddrCodeDecoder ACD(
        .clk_i(icache_ack_i),
		.rst_i(rst_i),
	    .opcode(ID_instr[31:26]),
        .swm_i(ID_swm),                      //input 
        .RS_base_i(ACD_base_select),         //input RS(base)
        .addrcode_i(ID_instr[20:0]),         //input addr_code			
        .stall_o(ID_ACD_stall),              //output                 
        .target_o(ID_ACD_src2),              //output
        .base_o(ID_ACD_base),                //output
        .memwrite(ID_ACD_memerite),
        .regwrite(ID_ACD_regwrite)			
    ); */
	
AddrCodeDecoder ACD(
        //.clk_i(icache_ack_i),
		.rst_i(rst_i),	                            
        .RS_base_i(ACD_base_select),         
        .addrcode_i(addrcode_lsm),
		.base_i(ACD_base_final),
        .swm_i(ID_swm),        
        .addrcode_o(addrcode_ACD_o),		
        .stall_o(ID_ACD_stall),                             
        .target_o(ID_ACD_src2),              
        .base_o(ID_ACD_base),
        .memwrite(memwrite_mls), 	   
	    .regwrite(regwrite_mls)		
    );
	
lsm_pipe lsm_pipe(
        .rst_i(rst_i),
	    .clk_i(clk_i),
		.remain_i(~icache_ack_i),
        .data_i(addrcode_ACD_o),
        .data_base_i(ID_ACD_base),		
		.data_o(addrcode_ACD_i),
       	.data_base_o(data_base_o)	
    );

	
lsm_fsm lsm_fsm(
        .rst_i(rst_i),
        .clk_i(clk_i),
		.iack_i(icache_ack_i),
        .data_i(ID_swm),
        .data_o(mux_lsm_sel)		
    ); 	


	
MUX_2to1 #(.size(21)) lsm(                //mux for addr
        .data0_i(ID_instr[20:0]),         //in
		.data1_i(addrcode_ACD_i),         //in             
	    .select_i(mux_lsm_sel),           //sel 
        .data_o(addrcode_lsm)             //out
    );
	
MUX_2to1 #(.size(32)) lsm_base(           //mux for base 
        .data0_i(ACD_base_select),        //in  from RF
		.data1_i(data_base_o),            //in  from pipe              
	    .select_i(mux_lsm_sel),           //sel 
        .data_o(ACD_base_final)           //out
    );	

Decoder Control(
		.funct_i(ID_instr[10:0]),
		.instr_op_i(ID_instr[31:26]),
		.RegWrite_o(ID_RegWrite),
		.ALU_op_o(ID_ALUOp),
		.ALUSrc_o(ID_ALUSrc),
		.RegDst_o(ID_RegDst),
		.Branch_o(ID_branch),
		.memread_o(ID_MemRead),
		.memwrite_o(ID_Memwrite),
		.memtoreg_o(ID_MemtoReg),
		.jr_o(ID_jr),
		.jump_o(ID_j),
		.jal_o(ID_jal),
		.memread_H_o(ID_MemRead_H),
		.memread_B_o(ID_MemRead_B),
		.memwrite_H_o(ID_MemWrite_H),    
		.memwrite_B_o(ID_MemWrite_B),
        .RegWrite_mult_o(ID_RegWrite_mult),
        .mfhi_o(ID_mfhi),
        .mflo_o(ID_mflo),
        .div_o(ID_div),
        .swm_o(ID_swm)			
	);
	
Sign_Extend Sign_Extend(
		.data_i(ID_instr[15:0]),
		.data_o(ID_Signextend)
	);	

MUX_2to1 #(.size(32)) base_or_extend(
        .data0_i(ID_Signextend),                  //in
		.data1_i(ID_ACD_base),                    //in             
	    .select_i(ID_swm),                         //sel 
        .data_o(ID_base_or_signedextend)         //out
    );

MUX_2to1 #(.size(165)) ID_EX_FLUSH(
		.data0_i(ID_EX_in),
		.data1_i(165'b0),
		.select_i(ID_Flush),
		.data_o(ID_decide)
	);

Pipe_Reg #(.size(165)) ID_EX(
		.rst_i(rst_i),
		.clk_i(clk_i),     
        .data_i(ID_decide), 
	    .remain(ALU_stall_o | ~icache_ack_i),
		.data_o(ID_EX_out)
	);

ALU_Ctrl ALU_Control(
        .funct_i(EX_ALUcontrol[5:0]),    //in
        .ALUOp_i(EX_ALUop),              //in
        .ALUCtrl_o(EX_ALUctrl_out)       //out			 
	);	

//Instantiate the components in EX stage

ALU ALU( 
        .stall_counter_i(EX_stall_counter),
        .src1_i(EX_Read_data_1_mux),            //in - src1_i   
        .src2_i(ALU_src_2),                     //in - src2_i
        .src3_i(EX_ALUcontrol[15:0]),           //in - src3_i			
	    .ctrl_i(EX_ALUctrl_out),                //in
		.temp_a_in(div_pipe_a_in),              //temp_a_in
		.temp_b_in(div_pipe_b_in),              //temp_b_in 
	    .result_o(EX_ALUrelt),                  //out
        .zero_o(EX_ALUZero),                    //out
	    .mult_data_o(EX_ALU_mult_data),
		.ALU_stall_o(ALU_stall_o),
		.stall_complete_o(EX_stall_complete),
        .temp_a_out(div_pipe_a_out),            //temp_a_out
        .temp_b_out(div_pipe_b_out) 	        //temp_b_out	 
	);
 
div_pipe div_pipe(
        .rst_i(rst_i),
	    .clk_i(clk_i),
        .data_i_1(div_pipe_a_out),
        .data_i_2(div_pipe_b_out),
		.data_o_1(div_pipe_a_in),
		.data_o_2(div_pipe_b_in)
    );		

counter counter(
        .rst_i(rst_i),
	    .clk_i(clk_i), 
		.div_i(EX_div),			  
        .div_stall(ALU_stall_o),         
		.stall_complete(EX_stall_complete),			   
		.stall_counter_o(EX_stall_counter)			  
    );
	
Forwarding_unit FORWARD(
		.MEM_RegWrite(MEM__WB[1]),
		.WB_RegWrite(RegWrite),
		.MEM_target(MEM_writereg),
		.WB_target(WB_WriteReg),
		.EX_RS(EX_rs),
		.EX_RT(EX_rt),
		.Forward_A(Forward_to_A),
		.Forward_B(Forward_to_B)
	);

MUX_2to1 #(.size(32)) Mux_Forward_jal(
        .data0_i(MEM_addr),                  //in
		.data1_i(MEM_PC),                    //in
		.select_i(MEM_jal),			         //sel
        .data_o(MEM_addr_jal)                //out
    );

MUX_3to1 #(.size(32)) ForwardA(
		.data0_i(EX_src1),     			     //src_1    
		.data1_i(MEM_addr_jal),              //src_2
		.data2_i(WB_WriteRegPcData),         //src_3
		.select_i(Forward_to_A),             //selection
		.data_o(ALU_src_1)                   //output
    );

MUX_3to1 #(.size(32)) ForwardB(
		.data0_i(EX_src2),     			
		.data1_i(MEM_addr_jal),         		
		.data2_i(WB_WriteRegPcData),      
	    .select_i(Forward_to_B),
		.data_o(EX_Write_MEM_Data)
    );
	
// this is the selection between signed entension and reg
MUX_2to1 #(.size(32)) Mux4(
        .data0_i(EX_Write_MEM_Data),          //in     from ForwardB
		.data1_i(EX_ALUcontrol),              //in     signed extension
		.select_i(EX_ALUSrc),
	    .data_o(ALU_src_2)
    );
	
//select write back reg is rd or rt?
MUX_2to1 #(.size(5)) Mux2(
        .data0_i(EX_rt),              //in
		.data1_i(EX_rd),              //in
		.select_i(EX_RegDst),		  //sel  
        .data_o(EX_mux2_out)          //out
    );

MUX_2to1 #(.size(5)) Mux2_jal(
        .data0_i(EX_mux2_out),                 //in
	    .data1_i(5'b11111),                    //in
	    .select_i(EX_jal),			           //sel
        .data_o(EX_mux2_out2)                  //out
    );		  
		 
MUX_2to1 #(.size(209)) EX_MEM_FLUSH(
		.data0_i(EX_MEM_in),
		.data1_i(209'b0),
		.select_i(EX_Flush),
		.data_o(EX_decide)
	);

Pipe_Reg #(.size(209)) EX_MEM(
	    .rst_i(rst_i),	 
        .clk_i(clk_i),                           //in
        .data_i(EX_decide),                      //in
		.remain(ALU_stall_o | ~icache_ack_i),
	    .data_o(EX_MEM_out)                      //out
    );
	
Adder add(
        .src1_i(EX_pc),                          //in
        .src2_i(EX_shift_out),                   //in
	    .sum_o(EX_add_out)                       //out     
    );

Shift_Left_Two_32  shift(
        .data_i(EX_ALUcontrol),     //in 
		.data_o(EX_shift_out)       //out
    );

//Instantiate the components in MEM stage
/*Data_Memory DM(
        clk_i,
        MEM_MemRead_H,
		MEM_MemRead_B,
		MEM_MemWrite_H,
		MEM_MemWrite_B,
        MEM_addr,                 //in
		MEM_writedata,	          //in
		MEM_read,  	              // 1
		MEM_write,      
	    MEM_readdata              //out 
	);*/


Pipe_Reg #(.size(169)) MEM_WB(
	    .rst_i(rst_i),
        .clk_i(clk_i),                            //in
        .data_i(MEM_WB_in),                        //in
		.remain(ALU_stall_o | ~icache_ack_i),
        .data_o(MEM_WB_out)                        //out			 
	);

//Instantiate the components in WB stage

MUX_2to1 #(.size(32)) Mux3(
		.data0_i(WB_memdata),
		.data1_i(WB_aludata),
		.select_i(WB_MemtoReg),
		.data_o(WB_WriteRegData)
    );
MUX_2to1 #(.size(32)) Mux3_WB_DATA(
		.data0_i(WB_WriteRegData),
		.data1_i(WB_PC),
		.select_i(WB_jal),
		.data_o(WB_WriteRegPcData)
    );		  
		  
/****************************************
signal assignment
****************************************/	
endmodule

