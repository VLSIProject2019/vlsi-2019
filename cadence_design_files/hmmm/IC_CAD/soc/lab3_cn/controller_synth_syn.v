/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : L-2016.03-SP4
// Date      : Wed Feb 27 12:10:13 2019
/////////////////////////////////////////////////////////////


module controller_synth ( ph1, ph2, reset, op, zero, memread, memwrite, 
        alusrca, memtoreg, iord, pcen, regwrite, regdst, pcsrc, alusrcb, aluop, 
        irwrite );
  input [5:0] op;
  output [1:0] pcsrc;
  output [1:0] alusrcb;
  output [1:0] aluop;
  output [3:0] irwrite;
  input ph1, ph2, reset, zero;
  output memread, memwrite, alusrca, memtoreg, iord, pcen, regwrite, regdst;
  wire   n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59,
         n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73,
         n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87,
         n88, n89, n90, n91, n92, n93, n94, n95;
  wire   [3:0] state;
  wire   [3:0] statelog_ns;
  wire   [3:0] statelog_statereg_mid;

  latch_c_1x statelog_statereg_slave_q_reg_3_ ( .ph(ph1), .d(
        statelog_statereg_mid[3]), .q(state[3]) );
  latch_c_1x statelog_statereg_master_q_reg_2_ ( .ph(ph2), .d(statelog_ns[2]), 
        .q(statelog_statereg_mid[2]) );
  latch_c_1x statelog_statereg_slave_q_reg_2_ ( .ph(ph1), .d(
        statelog_statereg_mid[2]), .q(state[2]) );
  latch_c_1x statelog_statereg_master_q_reg_1_ ( .ph(ph2), .d(statelog_ns[1]), 
        .q(statelog_statereg_mid[1]) );
  latch_c_1x statelog_statereg_slave_q_reg_1_ ( .ph(ph1), .d(
        statelog_statereg_mid[1]), .q(state[1]) );
  latch_c_1x statelog_statereg_master_q_reg_0_ ( .ph(ph2), .d(statelog_ns[0]), 
        .q(statelog_statereg_mid[0]) );
  latch_c_1x statelog_statereg_slave_q_reg_0_ ( .ph(ph1), .d(
        statelog_statereg_mid[0]), .q(state[0]) );
  latch_c_1x statelog_statereg_master_q_reg_3_ ( .ph(ph2), .d(statelog_ns[3]), 
        .q(statelog_statereg_mid[3]) );
  inv_1x U67 ( .a(state[1]), .y(n55) );
  inv_1x U68 ( .a(state[0]), .y(n53) );
  inv_1x U69 ( .a(n69), .y(n51) );
  inv_1x U70 ( .a(pcsrc[0]), .y(n46) );
  inv_1x U71 ( .a(pcsrc[1]), .y(n49) );
  inv_1x U72 ( .a(op[2]), .y(n74) );
  inv_1x U73 ( .a(op[1]), .y(n76) );
  inv_1x U74 ( .a(op[3]), .y(n91) );
  inv_1x U75 ( .a(alusrcb[1]), .y(n86) );
  inv_1x U76 ( .a(n63), .y(n60) );
  inv_1x U77 ( .a(state[2]), .y(n66) );
  inv_1x U78 ( .a(n46), .y(aluop[0]) );
  nand2_1x U79 ( .a(state[1]), .b(state[0]), .y(n72) );
  nand2_1x U80 ( .a(state[3]), .b(n66), .y(n84) );
  nor2_1x U81 ( .a(n72), .b(n84), .y(pcsrc[0]) );
  nor3_1x U82 ( .a(state[1]), .b(state[3]), .c(n66), .y(alusrcb[1]) );
  inv_1x U83 ( .a(state[3]), .y(n47) );
  nand2_1x U84 ( .a(n55), .b(n53), .y(n54) );
  nor3_1x U85 ( .a(n66), .b(n47), .c(n54), .y(pcsrc[1]) );
  nand2_1x U86 ( .a(n66), .b(n47), .y(n73) );
  nand2_1x U87 ( .a(pcsrc[0]), .b(zero), .y(n48) );
  nand3_1x U88 ( .a(n73), .b(n49), .c(n48), .y(pcen) );
  nor2_1x U89 ( .a(state[0]), .b(state[3]), .y(n63) );
  nor2_1x U90 ( .a(n55), .b(n60), .y(n69) );
  nor2_1x U91 ( .a(state[2]), .b(n51), .y(irwrite[2]) );
  nand2_1x U92 ( .a(state[0]), .b(n55), .y(n85) );
  nor2_1x U93 ( .a(n85), .b(n73), .y(irwrite[1]) );
  nor3_1x U94 ( .a(state[1]), .b(state[2]), .c(n60), .y(irwrite[0]) );
  nand2_1x U95 ( .a(n63), .b(n55), .y(n50) );
  nand2_1x U96 ( .a(n73), .b(n50), .y(alusrcb[0]) );
  nand2_1x U97 ( .a(n51), .b(n73), .y(memread) );
  and2_1x U98 ( .a(n86), .b(n84), .y(n52) );
  nor2_1x U99 ( .a(n53), .b(n52), .y(alusrca) );
  nor2_1x U100 ( .a(n84), .b(n54), .y(memwrite) );
  a2o1_1x U101 ( .a(n69), .b(state[2]), .c(memwrite), .y(iord) );
  nor3_1x U102 ( .a(state[0]), .b(n55), .c(n84), .y(regdst) );
  nor3_1x U103 ( .a(state[3]), .b(n66), .c(n72), .y(memtoreg) );
  or2_1x U104 ( .a(regdst), .b(memtoreg), .y(regwrite) );
  nor2_1x U105 ( .a(op[4]), .b(op[0]), .y(n62) );
  nor2_1x U106 ( .a(op[2]), .b(op[1]), .y(n57) );
  nor2_1x U107 ( .a(op[5]), .b(op[3]), .y(n75) );
  nand3_1x U108 ( .a(op[2]), .b(n75), .c(n76), .y(n88) );
  inv_1x U109 ( .a(n88), .y(n56) );
  a2o1_1x U110 ( .a(n57), .b(n91), .c(n56), .y(n58) );
  nand3_1x U111 ( .a(n57), .b(n62), .c(op[5]), .y(n64) );
  inv_1x U112 ( .a(n64), .y(n80) );
  a2o1_1x U113 ( .a(n62), .b(n58), .c(n80), .y(n59) );
  nor3_1x U114 ( .a(state[1]), .b(n66), .c(n59), .y(n61) );
  nor3_1x U115 ( .a(reset), .b(n61), .c(n60), .y(statelog_ns[0]) );
  inv_1x U116 ( .a(n62), .y(n90) );
  nand2_1x U117 ( .a(state[2]), .b(n63), .y(n79) );
  nor3_1x U118 ( .a(n90), .b(n88), .c(n79), .y(n70) );
  nor3_1x U119 ( .a(state[3]), .b(op[3]), .c(n64), .y(n65) );
  nor2_1x U120 ( .a(n66), .b(n65), .y(n67) );
  nor2_1x U121 ( .a(n85), .b(n67), .y(n68) );
  nor3_1x U122 ( .a(n70), .b(n69), .c(n68), .y(n71) );
  nor2_1x U123 ( .a(reset), .b(n71), .y(statelog_ns[1]) );
  nor2_1x U124 ( .a(n73), .b(n72), .y(irwrite[3]) );
  nand2_1x U125 ( .a(n75), .b(n74), .y(n87) );
  nor3_1x U126 ( .a(n76), .b(n90), .c(n87), .y(n77) );
  nor3_1x U127 ( .a(n77), .b(n80), .c(state[1]), .y(n78) );
  nor2_1x U128 ( .a(n79), .b(n78), .y(n82) );
  nand3_1x U129 ( .a(state[0]), .b(n80), .c(alusrcb[1]), .y(n92) );
  nor2_1x U130 ( .a(n92), .b(op[3]), .y(n81) );
  nor3_1x U131 ( .a(n82), .b(irwrite[3]), .c(n81), .y(n83) );
  nor2_1x U132 ( .a(reset), .b(n83), .y(statelog_ns[2]) );
  nor2_1x U133 ( .a(n85), .b(n84), .y(aluop[1]) );
  a2o1_1x U134 ( .a(n88), .b(n87), .c(n86), .y(n89) );
  nor3_1x U135 ( .a(state[0]), .b(n90), .c(n89), .y(n94) );
  nor2_1x U136 ( .a(n92), .b(n91), .y(n93) );
  nor3_1x U137 ( .a(aluop[1]), .b(n94), .c(n93), .y(n95) );
  nor2_1x U138 ( .a(reset), .b(n95), .y(statelog_ns[3]) );
endmodule

