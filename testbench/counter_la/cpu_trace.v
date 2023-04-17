`ifdef CPU_TRACE

// -------------------------------------------------
// CPU trace dump
// at most 5 characters in abi reg name
`define  CPU_INST  uut.soc.core.VexRiscv


reg [(8*5)-1:0] abi_reg[32]; // ABI register names

initial begin
 abi_reg[ 0] = "zero";
 abi_reg[ 1] = "ra";
 abi_reg[ 2] = "sp";
 abi_reg[ 3] = "gp";
 abi_reg[ 4] = "tp";
 abi_reg[ 5] = "t0";
 abi_reg[ 6] = "t1";
 abi_reg[ 7] = "t2";
 abi_reg[ 8] = "s0";
 abi_reg[ 9] = "s1";
 abi_reg[10] = "a0";
 abi_reg[11] = "a1";
 abi_reg[12] = "a2";
 abi_reg[13] = "a3";
 abi_reg[14] = "a4";
 abi_reg[15] = "a5";
 abi_reg[16] = "a6";
 abi_reg[17] = "a7";
 abi_reg[18] = "s2";
 abi_reg[19] = "s3";
 abi_reg[20] = "s4";
 abi_reg[21] = "s5";
 abi_reg[22] = "s6";
 abi_reg[23] = "s7";
 abi_reg[24] = "s8";
 abi_reg[25] = "s9";
 abi_reg[26] = "s10";
 abi_reg[27] = "s11";
 abi_reg[28] = "t3";
 abi_reg[29] = "t4";
 abi_reg[30] = "t5";
 abi_reg[31] = "t6";
end

// counter
int cycleCnt;
int commit_count;
initial begin
 cycleCnt = 0;
 commit_count = 0;
end

always @(negedge `CPU_INST.clk)
 cycleCnt <= cycleCnt+1;

// file handler of exec log
integer fd_el;

initial begin
 $timeformat(-9, 3, "ns",15);  // 1ns/1ps
 fd_el = $fopen("cpu_exec.log","w");
 if( fd_el == 0 ) begin
  $display("%t ERR %m, file cannot open", $time);
  $finish;
  end
 else begin
  $fwrite(fd_el, "// Cycle :   Count hart    pc    opcode    reg=value   ; mnemonic\n");
  $fwrite(fd_el, "//---------------------------------------------------------------\n");
  $fflush(fd_el);
  $display("%t MSG %m, cpu_exec.log generated", $time);
 end
end


`define CPU_w_CACHE
`define EXEC

`ifdef CPU_w_CACHE

`ifdef EXEC
/*
`define  CPU_PC      `CPU_INST.IBusCachedPlugin_fetchPc_pc
`define  CPU_CMDRDY  `CPU_INST.when_Fetcher_l158
`define  CPU_CMDRDY  `CPU_INST.when_Pipeline_l124_3
`define  CPU_CMDRDY  `CPU_INST.execute_arbitration_isValid
*/
`define  CPU_PC      `CPU_INST.execute_PC
`define  CPU_OPCODE  `CPU_INST.execute_INSTRUCTION
`define  CPU_OPCLGL  1'b1
`define  CPU_CMDVLD  `CPU_INST.execute_arbitration_isValid
`else
`define  CPU_PC      `CPU_INST.decode_PC
`define  CPU_OPCODE  `CPU_INST.decode_INSTRUCTION
`define  CPU_OPCLGL  `CPU_INST.decode_LEGAL_INSTRUCTION
`define  CPU_CMDVLD  `CPU_INST.decode_arbitration_isValid
`endif // EXEC

`else

`define  CPU_PC      `CPU_INST.IBusSimplePlugin_fetchPc_pc
`define  CPU_CMDRDY  `CPU_INST.iBus_cmd_ready
`define  CPU_OPCODE  `CPU_INST.execute_INSTRUCTION

`endif // CPU_w_CACHE

// update GPR value for later reference
always @(posedge `CPU_INST.clk) begin
 if( `CPU_INST.lastStageRegFileWrite_valid )
  gpr[`CPU_INST.lastStageRegFileWrite_payload_address] = `CPU_INST.lastStageRegFileWrite_payload_data;
end

string sss;
`define MAX_STR_LEN 33
reg [(8*`MAX_STR_LEN)-1:0] opcode_str;   // max 33 char in this string
reg [31:0]                 opcode_pc;    // program counter
initial begin
 opcode_str ="";
 opcode_pc  = 32'h0;
end


integer ii;

// trace monitor
always @(posedge `CPU_INST.clk) begin
 /*
 wb_valid[1:0]  <= '{`DEC.dec_i1_wen_wb,   `DEC.dec_i0_wen_wb};
 wb_dest[1:0]   <= '{`DEC.dec_i1_waddr_wb, `DEC.dec_i0_waddr_wb};
 wb_data[1:0]   <= '{`DEC.dec_i1_wdata_wb, `DEC.dec_i0_wdata_wb};
 */
 /*
 if( U_MY_SOC0.U_SOC_CORE_0.trace_rv_i_valid_ip !== 0) begin
 */
 /*
 if( `CPU_CMDRDY ) begin
 */
 if( ~`CPU_INST.reset && `CPU_OPCLGL && `CPU_CMDVLD ) begin
  // Basic trace - no exception register updates
  // #1 0 ee000000 b0201073 c 0b02       00000000
  /*
  for(int i=0; i<2; i++ )
   if (U_MY_SOC0.U_SOC_CORE_0.trace_rv_i_valid_ip[i]==1) begin
  */
    sss = dasm(`CPU_OPCODE, `CPU_PC, 5'b00000, 32'h0);
    commit_count <= commit_count + 1;
    $fwrite(fd_el, "%8d : %7s %04d %h %h%13s ; %s\n", cycleCnt,                                // Cycle #
                                                      $sformatf("#%0d",commit_count),          // Commit #
                                                      0,                                       // Hardware Thread ID, HART
                                                   // U_MY_SOC0.U_SOC_CORE_0.trace_rv_i_address_ip[31+i*32 -:32],
                                                      `CPU_PC,
                                                   // U_MY_SOC0.U_SOC_CORE_0.trace_rv_i_insn_ip[31+i*32-:32],
                                                      `CPU_OPCODE,
                                                   // (wb_dest[i] !=0 && wb_valid[i]) ?  $sformatf("%s=%h", abi_reg[wb_dest[i]], wb_data[i]) : "             ",
                                                      "             ",
                                                      /*
                                                      dasm(U_MY_SOC0.U_SOC_CORE_0.trace_rv_i_insn_ip[31+i*32 -:32],
                                                           U_MY_SOC0.U_SOC_CORE_0.trace_rv_i_address_ip[31+i*32-:32],
                                                           wb_dest[i] & {5{wb_valid[i]}},
                                                           wb_data[i])
                                                      */ 
                                                      /*
                                                      dasm(`CPU_OPCODE,
                                                           `CPU_PC,
                                                           5'b00000,        // regn[4:0], index to 0 ~ 31, which GPR will be update with regv
                                                           32'h0)           // regv, new GPR register data value
                                                      */
                                                      sss
           );
    // convert string data type to reg[]
    for(ii=0 ; ii < `MAX_STR_LEN ; ii=ii+1)
     opcode_str[(8*ii)+:8] = sss[`MAX_STR_LEN-1-ii];

    opcode_pc = `CPU_PC;
// end // if
 end // if

 /*
 if(`DEC.dec_nonblock_load_wen) begin
  $fwrite(fd_el, "%10d : %10d%22s=%h ; nbL\n", cycleCnt,
                                               0, 
                                               abi_reg[`DEC.dec_nonblock_load_waddr], 
                                               `DEC.lsu_nonblock_load_data
         );
  tb_top.gpr[0][`DEC.dec_nonblock_load_waddr] = `DEC.lsu_nonblock_load_data;
 end
 */

end // always

`include "dasm.v"

`endif // CPU_TRACE


