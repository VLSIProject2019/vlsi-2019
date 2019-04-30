//--------------------------------------------------------


`timescale 1ns / 100ps


module testbench();
    logic[7:0] a, y;
    logic en;
    
    // The device under test
    tristate_1x_8 dut(y, a, en, ~en);

	`include "testfixture.verilog"
    
endmodule

/*module tristates(input  logic[7:0] a,
             input  logic en,
             output logic[7:0] y);
             
   assign #1 y = en ? a : 8'bz;    
endmodule//*/

