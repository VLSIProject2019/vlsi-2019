module testbench();
    logic a, en, enBar, y;

    // The device under test
    tristate dut(a, en, enBar, y);

        `include "testfixture.verilog"

endmodule

module tristate(input  logic a,
                input  logic en,
                input  logic enBar,
                output logic y);

   assign #1 y = en ? ~a : 1'bz;
endmodule

