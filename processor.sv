// microprocessor

module top (input logic       clk, reset,
				input logic       memWrite,
				input logic [7:0] adr,
				input logic [9:0] instruct);
endmodule

module datapath ();
endmodule

module controller ();
endmodule

module alu (input logic [3:0]  d0, d1,
				input logic        subtractionControl,
				output logic [3:0] result);
	logic [3:0] condinvb;
	assign condinvb = subtractionControl ? ~b : b;
	assign result = a + condinvb + subtractionControl;
endmodule

module flopr #(parameter WIDTH = 8)
              (input  logic             clk, reset,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);
	always_ff @(posedge clk, posedge reset)
		if (reset) q <= 0;
		else       q <= d;
endmodule

module mux2 #(parameter WIDTH = 4)
				(input  logic [WIDTH-1:0] d0, d1, 
				 input  logic             s, 
				 output logic [WIDTH-1:0] y);
	assign y = s ? d1 : d0; 
endmodule
