// microprocessor

module top ();
endmodule

module alu (input logic [3:0]  d0, d1,
				input logic        subtractionControl,
				output logic [3:0] result);
	logic [3:0] condinvb;
	assign condinvb = subtractionControl ? ~b : b;
	assign result = a + condinvb + subtractionControl;
endmodule

module mux2 #(parameter WIDTH = 4)
				(input  logic [WIDTH-1:0] d0, d1, 
				 input  logic             s, 
				 output logic [WIDTH-1:0] y);
	assign y = s ? d1 : d0; 
endmodule
