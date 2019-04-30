//---------------------------------------------------------
// nand2.sv
// Nathaniel Pinckney 08/06/07
//
// Model and testbench of NAND2 gate
//--------------------------------------------------------

module testbench();
    logic[7:0] a, y;
    logic en;
    
    // The device under test
    tristates dut(a, en, y);

	`include "testfixture.verilog"
    
endmodule

module tristates(input  logic[7:0] a,
             input  logic en,
             output logic[7:0] y);
             
   assign #1 y = en ? a : 8'bz;    
endmodule

