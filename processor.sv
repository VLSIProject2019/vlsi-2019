// microprocessor

module top (input logic       clk, reset,
				input logic       memWrite,
				input logic [7:0] adr,
				input logic [9:0] instruct);
	controller c(clk, reset, instruct[9:6],
					 branchRegVal,
					 PCS, RegWrite, MemWrite
					 ALUOp, ALUSrc);
	datapat dp(clk, reset, instruct[5:0],
				  PCS, RegWrite, MemWrite,
				  ALUOp, ALUSrc,
				  branchRegVal);
endmodule

module datapath (input logic       clk, reset,
					  input logic[5:0]  instruct,
					  input logic       PCS, RegWrite, MemWrite,
					  input logic       ALUOp, ALUSrc,
					  output logic[3:0] branchRegVal);
	logic[7:0] PC, PCNext, PCPlus1;
	logic[3:0] Result, SrcA, SrcB;
	logic[3:0] RA1, RA2, WA3, WD3, RD1, RD2;
	
	// next PC logic
	adder #(8) pcAdd(PC, 8'b1, PCPlus1);
	flopr #(8) pcReg(clk, reset, PCNext, PC);
	
	//register read/write logic
	assign WA3 = instruct[5:4];
	assign RA1 = instruct[3:2];
	assign RA2 = instruct[1:0];
	// this next line will change when we add loadr and setn: ***
	assign WD3 = Result;
	regfile rf(clk, RegWrite, RA1, RA2,
				  WA3, WD3, RD1, RD2);
	
	// ALU logic
	mux2 #(4) srcAMux(4'b0, RD1, ALUSrc, SrcA);
	mux2 #(4) srcBMux(RD1, RD2, ALUSrc, SrcB);
	alu alu(SrcA, SrcB, ALUOp, Result);
	
endmodule

module controller (input logic       clk, reset,
						 input logic[3:0]  funct,
						 input logic[3:0]  branchRegVal,
						 output logic PCS, RegWrite, MemWrite,
						 output logic ALUOp, ALUSrc);
	// branch
	condcheck cc(funct[1:0], branchRegVal, condBranch);
	// ^ need to connect regVal to the datapath to check********
	assign PCS = funct[3] & (funct[2] | condBranch);
	
	// memory
	assign MemWrite = ~funct[3] & ~funct[2] & funct[1] & funct[0];
	
	//data processing
	assign RegWrite = ~funct[3] & (funct[2] | funct[0]);
	assign ALUSrc = funct[1]; // if 0, A = 0, else A = the reg value
	assign ALUOp = funct[0];
endmodule

module condcheck (input logic[1:0] branchType,
						input logic[3:0] branchRegVal,
						output logic     condBranch);
	logic zero, negative;
	assign negative = branchRegVal[3];
	assign zero = ~(|branchRegVal);
	always_comb
		case(branchType)
			2'b00: // jeqzn
				condBranch = zero; break;
			2'b01: // jneqzn
				condBranch = ~zero; break;
			2'b10: // jgtzn
				condBranch = ~negative & ~zero;
			2'b11: // jltzn
				condBranch = negative; // if negative then also nonzero
			default:
				condBranch = 1'bx;
		endcase
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

module mux3 #(parameter WIDTH = 4)
				 (input  logic [WIDTH-1:0] d0, d1, d2,
              input  logic [1:0]       s, 
              output logic [WIDTH-1:0] y);
	assign y = s[1] ? (s[0] ? 32'bx : d2) : (s[0] ? d1 : d0);
endmodule
