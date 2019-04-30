/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : L-2016.03-SP4
// Date      : Mon Mar 18 03:08:33 2019
/////////////////////////////////////////////////////////////


module controller ( ph1, ph2, reset, funct, negative, zero, RA1Src, PCEnable, 
        AdrSrc, InstrSrc, RegWrite, TwoRegs, ALUSub, PCSrc, RegWriteSrc, 
        MemWrite );
  input [3:0] funct;
  output [1:0] PCSrc;
  output [1:0] RegWriteSrc;
  input ph1, ph2, reset, negative, zero;
  output RA1Src, PCEnable, AdrSrc, InstrSrc, RegWrite, TwoRegs, ALUSub,
         MemWrite;
  wire   stateReg_N3, stateReg_nextQ_0_, n14, n15, n16, n17, n18, n19, n20,
         n21, n22, n23, n24, n25;

  latch_c_1x stateReg_q_reg_0_ ( .ph(ph1), .d(stateReg_nextQ_0_), .q(AdrSrc)
         );
  latch_c_1x stateReg_nextQ_reg_0_ ( .ph(ph2), .d(stateReg_N3), .q(
        stateReg_nextQ_0_) );
  inv_1x U24 ( .a(AdrSrc), .y(InstrSrc) );
  inv_1x U25 ( .a(funct[1]), .y(n14) );
  inv_1x U26 ( .a(funct[3]), .y(n16) );
  inv_1x U27 ( .a(funct[2]), .y(n15) );
  inv_1x U28 ( .a(n15), .y(RegWriteSrc[1]) );
  inv_1x U29 ( .a(n22), .y(ALUSub) );
  inv_1x U30 ( .a(n14), .y(TwoRegs) );
  inv_1x U31 ( .a(n16), .y(RA1Src) );
  nor2_1x U32 ( .a(funct[2]), .b(n14), .y(RegWriteSrc[0]) );
  nand3_1x U33 ( .a(RegWriteSrc[0]), .b(AdrSrc), .c(n16), .y(n17) );
  nor3_1x U34 ( .a(funct[0]), .b(reset), .c(n17), .y(MemWrite) );
  nor2_1x U35 ( .a(funct[2]), .b(funct[0]), .y(n18) );
  nor3_1x U36 ( .a(n18), .b(funct[3]), .c(InstrSrc), .y(RegWrite) );
  nand2_1x U37 ( .a(n16), .b(InstrSrc), .y(PCEnable) );
  nor2_1x U38 ( .a(reset), .b(PCEnable), .y(stateReg_N3) );
  nor3_1x U39 ( .a(funct[0]), .b(negative), .c(zero), .y(n19) );
  a2o1_1x U40 ( .a(negative), .b(funct[0]), .c(n19), .y(n20) );
  a2o1_1x U41 ( .a(n15), .b(n20), .c(n14), .y(n21) );
  nand2_1x U42 ( .a(funct[3]), .b(n21), .y(n25) );
  inv_1x U43 ( .a(funct[0]), .y(n22) );
  mux2_c_1x U44 ( .d0(funct[0]), .d1(n22), .s(zero), .y(n23) );
  nor3_1x U45 ( .a(funct[2]), .b(funct[1]), .c(n23), .y(n24) );
  nor2_1x U46 ( .a(n25), .b(n24), .y(PCSrc[0]) );
  nor3_1x U47 ( .a(n15), .b(n14), .c(n16), .y(PCSrc[1]) );
endmodule

