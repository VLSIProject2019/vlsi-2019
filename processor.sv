// microprocessor

module top (input  logic        clk, reset,
				output logic        MemWrite,
				output logic [7:0]  adr, WriteData,
				input  logic [14:0] ReadData);
	//memory(MemWrite, Adr, WriteData, ReadData);
	logic PCEnable, AdrSrc, InstrSrc, RegWrite, TwoRegs, ALUSrc;
	logic [1:0] PCSrc, RegWriteSrc;
	
	controller c(clk, reset, PCEnable, AdrSrc, InstrSrc, RegWrite,
						TwoRegs, ALUSub, PCSrc, RegWriteSrc, MemWrite);
	datapath dp(clk, reset, PCEnable, AdrSrc, InstrSrc,
					RegWrite, TwoRegs, ALUSub, PCSrc,
					RegWriteSrc, ReadData, Adr, WriteData);
endmodule

module datapath (input  logic        clk, reset,
					  input  logic        PCEnable, AdrSrc, InstrSrc,
					  input  logic        RegWrite, TwoRegs, ALUSub,
					  input  logic [1:0]  PCSrc, RegWriteSrc,
					  input  logic [14:0] ReadData,
					  output logic [7:0]  Adr, WriteData);
	logic[7:0]  PC, PCNext, PCPlus1;
	logic[7:0]  Result, SrcA, SrcB, Imm;
	logic[7:0]  WD3, RD1, RD2, notRD2;
	logic[3:0]  RA1, RA2, WA3;
	logic[15:0] instrTemp, instr;
	
	// next PC logic
	adder   #(8) pcAdd(PC, 8'b1, 1'b0, PCPlus1);
	flopenr #(8) pcReg(clk, reset, PCNext, PC);
	mux3    #(8) pcMux(PCPlus1, Imm, RD1, PCSrc, PCNext);
	
	// data memory
	mux2 #(8) adrMux(PC, RD2, AdrSrc, Adr);
	assign WriteData = RD1;
	
	//instruction handling
	flopr #(15) instrReg(clk, reset, ReadData, instrTemp);
	mux2  #(15) instrMux(instrTemp, ReadData, InstrSrc, instr);
	
	//register read/write logic
	mux3 #(8)  wd3Mux(Imm, ReadData[7:0], Result, RegWriteSrc, WD3);
	regfile rf(clk, RegWrite, RA1, RA2, WA3, WD3, RD1, RD2);
	assign RA1 = instr[9:7];
	assign RA2 = instr[12:10];
	assign WA3 = instr[6:4];
	assign Imm = instr[7:14];
	
	// ALU logic
	mux2 #(8) srcAMux(8'b0, RD1, TwoRegs, SrcA);
	assign notRD2 = ~RD2;
	mux2 #(8) srcBMux(RD2, notRD2, ALUSub, SrcB);
	adder #(8) alu(SrcA, SrcB, ALUSub, Result);
endmodule

module controller (input  logic      clk, reset,
						 output logic      PCEnable, AdrSrc, InstrSrc,
					    output logic      RegWrite, TwoRegs, ALUSub,
					    output logic[1:0] PCSrc, RegWriteSrc,
						 output logic      MemWrite);
	/*logic condBranch;
	// branch
	condcheck cc(funct[1:0], branchRegVal, condBranch);
	assign PCS = funct[3] & (funct[2] | condBranch);
	
	// memory
	assign MemWrite = ~funct[3] & ~funct[2] & funct[1] & funct[0];
	
	//data processing
	assign RegWrite = ~funct[3] & (funct[2] | funct[0]);
	assign ALUSrc = funct[1]; // if 0, A = 0, else A = the reg value
	assign ALUOp = funct[0];
	
	//write-back
	always_comb
		if(funct[2])
			RegWriteSrc = 2'b00; // Result
		else if(funct[1])
			RegWriteSrc = 2'b01; //ReadData
		else
			RegWriteSrc = 2'b10; //extImm*/
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
				condBranch = zero;
			2'b01: // jneqzn
				condBranch = ~zero;
			2'b10: // jgtzn
				condBranch = ~negative & ~zero;
			2'b11: // jltzn
				condBranch = negative; // if negative then also nonzero
			default:
				condBranch = 1'bx;
		endcase
endmodule

/*module alu (input logic [3:0]  a, b,
				input logic        subtractionControl,
				output logic [3:0] result);
	logic [3:0] condinvb;
	assign condinvb = subtractionControl ? ~b : b;
	assign result = a + condinvb + subtractionControl;
endmodule*/

module adder #(parameter WIDTH=8)
              (input  logic [WIDTH-1:0] a, b,
				   input  logic cin,
               output logic [WIDTH-1:0] y);
	assign y = a + b + cin;
endmodule

module regfile(input  logic       clk, 
               input  logic       we3, 
               input  logic [3:0] ra1, ra2, wa3, 
               input  logic [7:0] wd3,
               output logic [7:0] rd1, rd2);
	// note: can't read PC in HMMM
	logic [7:0] rf[7:0];
	
	always_ff @(posedge clk)
		if (we3) rf[wa3] <= wd3;
	assign rd1 = rf[ra1];
	assign rd2 = rf[ra2];
endmodule

module flopenr #(parameter WIDTH = 8)
                (input  logic             clk, reset, en,
                 input  logic [WIDTH-1:0] d, 
                 output logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if (reset)   q <= 0;
    else if (en) q <= d;
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
