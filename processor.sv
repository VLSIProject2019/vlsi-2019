// microprocessor

module top (input logic       clk, reset,
				input logic       memWrite,
				input logic [7:0] adr,
				input logic [9:0] instruct);
	controller c(clk, reset, instruct[9:6],
					 branchRegVal,
					 PCS, RegWrite, MemWrite);
	datapat dp(clk, reset, instruct[5:0],
				  branchRegVal,
				  PCS, RegWrite, MemWrite);
endmodule

module datapath (input logic       clk, reset,
					  input logic[5:0]  instruct,
					  input logic       PCS, RegWrite, MemWrite,
					  output logic[3:0] branchRegVal);
	logic [7:0] PC, PCNext, PCPlus1;
	
	// next PC logic
	adder #(8) pcAdd(PC, 8'b1, PCPlus1);
	flopr #(8) pcReg(clk, reset, PCNext, PC);
	
endmodule

module controller (input logic       clk, reset,
						 input logic[3:0]  funct,
						 input logic[3:0]  branchRegVal,
						 output logic PCS, RegWrite, MemWrite);
	// branch
	condcheck cc(funct[1:0], branchRegVal, condBranch);
	// ^ need to connect regVal to the datapath to check********
	assign PCS = funct[3] & condBranch; // branch
	
	// memory
	
	//data processing
endmodule

module condcheck (input logic[1:0] branchType,
						input logic[3:0] branchRegVal,
						output logic     condBranch);
	logic zero, negative;
	assign negative = branchRegVal[3];
	// assign zero to bitwise and of branchRegVal
	// I don't have my document with all the encoding with me so
	// I'll finish this later **********************
endmodule

module alu (input logic [3:0]  d0, d1,
				input logic        subtractionControl,
				output logic [3:0] result);
	logic [3:0] condinvb;
	assign condinvb = subtractionControl ? ~b : b;
	assign result = a + condinvb + subtractionControl;
endmodule

module adder #(parameter WIDTH=8)
              (input  logic [WIDTH-1:0] a, b,
               output logic [WIDTH-1:0] y);
	assign y = a + b;
endmodule

module regfile(input  logic       clk, 
               input  logic       we3, 
               input  logic [1:0] ra1, ra2, wa3, 
               input  logic [3:0] wd3,
               output logic [3:0] rd1, rd2);
	// note: can't read PC in HMMM
	
	logic [3:0] rf[1:0];
	
	always_ff @(posedge clk)
		if (we3) rf[wa3] <= wd3;
	
	assign rd1 = rf[ra1];
	assign rd2 = rf[ra2];
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
