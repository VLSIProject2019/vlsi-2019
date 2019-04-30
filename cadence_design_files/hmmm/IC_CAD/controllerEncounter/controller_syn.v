/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : L-2016.03-SP4
// Date      : Mon Mar 25 04:07:49 2019
/////////////////////////////////////////////////////////////


module controller ( ph1, ph2, reset, negative, zero, RegWLoadSrc, RA1Src, 
        PCEnable, AdrSrc, InstrSrc, RegWrite, TwoRegs, ALUSub, PCSrc, 
        RegWriteSrc, MemWrite, MemData1, instr1 );
  output [1:0] PCSrc;
  output [1:0] RegWriteSrc;
  input [14:8] MemData1;
  output [14:8] instr1;
  input ph1, ph2, reset, negative, zero;
  output RegWLoadSrc, RA1Src, PCEnable, AdrSrc, InstrSrc, RegWrite, TwoRegs,
         ALUSub, MemWrite;
  wire   instrReg1_N9, instrReg1_N8, instrReg1_N7, instrReg1_N6, instrReg1_N5,
         instrReg1_N4, instrReg1_N3, stateReg_N3, stateReg_nextQ_0_, n19, n20,
         n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34,
         n35, n36;
  wire   [14:8] instrTemp1;
  wire   [6:0] instrReg1_nextQ;

  latch_c_1x instrReg1_nextQ_reg_0_ ( .ph(ph2), .d(instrReg1_N3), .q(
        instrReg1_nextQ[0]) );
  latch_c_1x instrReg1_nextQ_reg_1_ ( .ph(ph2), .d(instrReg1_N4), .q(
        instrReg1_nextQ[1]) );
  latch_c_1x instrReg1_nextQ_reg_2_ ( .ph(ph2), .d(instrReg1_N5), .q(
        instrReg1_nextQ[2]) );
  latch_c_1x instrReg1_nextQ_reg_3_ ( .ph(ph2), .d(instrReg1_N6), .q(
        instrReg1_nextQ[3]) );
  latch_c_1x instrReg1_nextQ_reg_4_ ( .ph(ph2), .d(instrReg1_N7), .q(
        instrReg1_nextQ[4]) );
  latch_c_1x instrReg1_nextQ_reg_5_ ( .ph(ph2), .d(instrReg1_N8), .q(
        instrReg1_nextQ[5]) );
  latch_c_1x instrReg1_nextQ_reg_6_ ( .ph(ph2), .d(instrReg1_N9), .q(
        instrReg1_nextQ[6]) );
  latch_c_1x instrReg1_q_reg_0_ ( .ph(ph1), .d(instrReg1_nextQ[0]), .q(
        instrTemp1[8]) );
  latch_c_1x instrReg1_q_reg_1_ ( .ph(ph1), .d(instrReg1_nextQ[1]), .q(
        instrTemp1[9]) );
  latch_c_1x instrReg1_q_reg_2_ ( .ph(ph1), .d(instrReg1_nextQ[2]), .q(
        instrTemp1[10]) );
  latch_c_1x instrReg1_q_reg_3_ ( .ph(ph1), .d(instrReg1_nextQ[3]), .q(
        instrTemp1[11]) );
  latch_c_1x instrReg1_q_reg_4_ ( .ph(ph1), .d(instrReg1_nextQ[4]), .q(
        instrTemp1[12]) );
  latch_c_1x instrReg1_q_reg_5_ ( .ph(ph1), .d(instrReg1_nextQ[5]), .q(
        instrTemp1[13]) );
  latch_c_1x instrReg1_q_reg_6_ ( .ph(ph1), .d(instrReg1_nextQ[6]), .q(
        instrTemp1[14]) );
  latch_c_1x stateReg_q_reg_0_ ( .ph(ph1), .d(stateReg_nextQ_0_), .q(AdrSrc)
         );
  latch_c_1x stateReg_nextQ_reg_0_ ( .ph(ph2), .d(stateReg_N3), .q(
        stateReg_nextQ_0_) );
  inv_1x U44 ( .a(n22), .y(InstrSrc) );
  inv_1x U45 ( .a(RegWriteSrc[1]), .y(n21) );
  inv_1x U46 ( .a(RA1Src), .y(n24) );
  inv_1x U47 ( .a(TwoRegs), .y(n20) );
  inv_1x U48 ( .a(ALUSub), .y(n19) );
  inv_1x U49 ( .a(n29), .y(n22) );
  inv_1x U50 ( .a(n19), .y(instr1[11]) );
  inv_1x U51 ( .a(n21), .y(instr1[13]) );
  nor2_1x U52 ( .a(reset), .b(AdrSrc), .y(n29) );
  mux2_c_1x U53 ( .d0(instrTemp1[11]), .d1(MemData1[11]), .s(InstrSrc), .y(
        ALUSub) );
  mux2_c_1x U54 ( .d0(instrTemp1[12]), .d1(MemData1[12]), .s(InstrSrc), .y(
        TwoRegs) );
  inv_1x U55 ( .a(n20), .y(instr1[12]) );
  mux2_c_1x U56 ( .d0(instrTemp1[13]), .d1(MemData1[13]), .s(InstrSrc), .y(
        RegWriteSrc[1]) );
  nor2_1x U57 ( .a(MemData1[14]), .b(n22), .y(stateReg_N3) );
  nor2_1x U58 ( .a(InstrSrc), .b(instrTemp1[14]), .y(n23) );
  nor2_1x U59 ( .a(stateReg_N3), .b(n23), .y(RA1Src) );
  inv_1x U60 ( .a(n24), .y(instr1[14]) );
  nor2_1x U61 ( .a(n20), .b(RegWriteSrc[1]), .y(RegWriteSrc[0]) );
  nand3_1x U62 ( .a(n24), .b(ALUSub), .c(RegWriteSrc[0]), .y(n25) );
  inv_1x U63 ( .a(n25), .y(RegWLoadSrc) );
  inv_1x U64 ( .a(AdrSrc), .y(n27) );
  nand2_1x U65 ( .a(n27), .b(n24), .y(PCEnable) );
  inv_1x U66 ( .a(reset), .y(n30) );
  nand3_1x U67 ( .a(n19), .b(RegWriteSrc[0]), .c(n30), .y(n26) );
  nor3_1x U68 ( .a(instrTemp1[14]), .b(n27), .c(n26), .y(MemWrite) );
  nor2_1x U69 ( .a(RegWriteSrc[1]), .b(ALUSub), .y(n28) );
  nor3_1x U70 ( .a(n28), .b(instrTemp1[14]), .c(n27), .y(RegWrite) );
  mux2_c_1x U71 ( .d0(instrTemp1[8]), .d1(MemData1[8]), .s(n29), .y(instr1[8])
         );
  mux2_c_1x U72 ( .d0(instrTemp1[9]), .d1(MemData1[9]), .s(n29), .y(instr1[9])
         );
  mux2_c_1x U73 ( .d0(instrTemp1[10]), .d1(MemData1[10]), .s(InstrSrc), .y(
        instr1[10]) );
  and2_1x U74 ( .a(MemData1[8]), .b(n30), .y(instrReg1_N3) );
  and2_1x U75 ( .a(MemData1[9]), .b(n30), .y(instrReg1_N4) );
  and2_1x U76 ( .a(MemData1[10]), .b(n30), .y(instrReg1_N5) );
  and2_1x U77 ( .a(MemData1[11]), .b(n30), .y(instrReg1_N6) );
  and2_1x U78 ( .a(MemData1[12]), .b(n30), .y(instrReg1_N7) );
  and2_1x U79 ( .a(MemData1[13]), .b(n30), .y(instrReg1_N8) );
  and2_1x U80 ( .a(MemData1[14]), .b(n30), .y(instrReg1_N9) );
  mux2_c_1x U81 ( .d0(ALUSub), .d1(n19), .s(zero), .y(n31) );
  nor3_1x U82 ( .a(TwoRegs), .b(RegWriteSrc[1]), .c(n31), .y(n36) );
  nor3_1x U83 ( .a(negative), .b(zero), .c(ALUSub), .y(n32) );
  a2o1_1x U84 ( .a(negative), .b(ALUSub), .c(n32), .y(n33) );
  a2o1_1x U85 ( .a(n21), .b(n33), .c(n20), .y(n34) );
  nand2_1x U86 ( .a(RA1Src), .b(n34), .y(n35) );
  nor2_1x U87 ( .a(n36), .b(n35), .y(PCSrc[0]) );
  nor3_1x U88 ( .a(n20), .b(n21), .c(n24), .y(PCSrc[1]) );
endmodule

