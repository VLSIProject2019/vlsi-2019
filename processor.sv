// Microprocessor for E190AT: VLSI Design Project
// Authors: Erik Meike, Caleb Norfleet, & Kaveh Pezeshki
// Created Spring 2019

module top (input  logic        ph1, ph2, reset,
				output logic        MemWrite,
				output logic [7:0]  Adr,
				input  logic [14:8] MemData1,
				inout  logic [7:0]  MemData2);
	
	logic PCEnable, AdrSrc, InstrSrc, RegWrite;
	logic TwoRegs, ALUSub, negative, zero;
	logic [1:0] PCSrc, RegWriteSrc;
	logic [3:0] funct;
	
	controller c(ph1, ph2, reset, funct, negative, zero,
					 PCEnable, AdrSrc, InstrSrc, RegWrite, TwoRegs,
					 ALUSub, PCSrc, RegWriteSrc, MemWrite);
	datapath dp(ph1, ph2, reset, PCEnable, AdrSrc, InstrSrc,
					RegWrite, MemWrite, TwoRegs, ALUSub, PCSrc,
					RegWriteSrc,
					MemData1,
					MemData2,
					Adr, negative, zero, funct);
endmodule

module datapath (input  logic        ph1, ph2, reset,
					  input  logic        PCEnable, AdrSrc, InstrSrc,
					  input  logic        RegWrite, MemWrite, TwoRegs, ALUSub,
					  input  logic [1:0]  PCSrc, RegWriteSrc,
					  input  logic [14:8] MemData1,
					  inout  logic [7:0]  MemData2,
					  output logic [7:0]  Adr,
					  output logic        negative, zero,
					  output logic [3:0]  funct);
	logic[7:0]  PC, PCNext, PCPlus1;
	logic[7:0]  Result, SrcA, SrcB, Imm;
	logic[7:0]  WD3, RD1, RD2;
	logic[7:0]  WriteData;
	logic[3:0]  RA1, RA2, WA3;
	logic[14:8] instrTemp1, instr1;
	logic[7:0] instrTemp2, instr2;
	
	// next PC logic
	adder   #(8) pcAdd(PC, 8'b1, 1'b0, PCPlus1);
	flopenr #(8) pcReg(ph1, ph2, reset, PCEnable, PCNext, PC);
	mux3    #(8) pcMux(PCPlus1, Imm, RD1, PCSrc, PCNext);
	
	// data memory
	mux2 #(8) adrMux(PC, RD2, AdrSrc, Adr);
	assign WriteData = RD1;
	
	// instruction handling
	flopr #(7) instrReg1(ph1, ph2, reset, MemData1, instrTemp1);
	flopr #(8) instrReg2(ph1, ph2, reset, MemData1, instrTemp2);
	mux2  #(7) instrMux1(instrTemp1, MemData1, InstrSrc, instr1);
	mux2  #(8) instrMux2(instrTemp2, MemData2, InstrSrc, instr2);
	// note: currently instrMux is kinda useless :)
	assign funct = instr1[14:11];
	
	// register read/write logic
	mux3 #(8) wd3Mux(Imm, MemData2[7:0], Result, RegWriteSrc, WD3);
	regfile   rf(ph1, ph2, reset, RegWrite, RA1, RA2, WA3, WD3, RD1, RD2);
	assign RA1 = instr2[7:5];
	assign RA2 = instr2[4:2];
	assign WA3 = instr1[10:8];
	assign Imm = instr2[7:0];
	
	
	// tristate for handling write data
	assign MemData2[7:0]  = (MemWrite ? WriteData : 8'bz);
	
	// zero and negative for conditional branching
	assign negative = RD1[7];
	assign zero = ~(|RD1);
	
	// ALU logic
	assign SrcB = ALUSub ^ RD2;
	// ^same as: mux2  #(8) srcBMux(RD2, notRD2, ALUSub, SrcB);
	mux2  #(8) srcAMux(8'b0, RD1, TwoRegs, SrcA);
	adder #(8) alu(SrcA, SrcB, ALUSub, Result);
endmodule

module controller (input  logic      ph1, ph2, reset,
						 input  logic[3:0] funct,
						 input  logic      negative, zero,
						 output logic      PCEnable, AdrSrc, InstrSrc,
					    output logic      RegWrite, TwoRegs, ALUSub,
					    output logic[1:0] PCSrc, RegWriteSrc,
						 output logic      MemWrite);
	logic state, stateBar, condBranch;
	
	// cycle clock "FSM" (0=instr read, 1=load/write back)
	flopr #(1) stateReg(ph1, ph2, reset, stateBar, state);
	assign stateBar = ~state;
	
	assign PCEnable = state;
	assign AdrSrc   = state;
	assign InstrSrc = stateBar;
	
	// branch
	condcheck cc(funct[3:2], negative, zero, condBranch);
	// funct[0] is branch, funct[1] is unconditional
	assign PCSrc = (funct[0] & (funct[1] | condBranch)) ?
						((funct[1] & funct[2]) ?
						2'b10 : 2'b01) : 2'b00;
	
	// data processing
	assign TwoRegs = funct[2];
	assign ALUSub  = funct[3];
	
	// writeback
	assign MemWrite = stateBar & (funct == 4'b0100);
	assign RegWrite = stateBar & ~funct[0] & (funct[1] | funct[3]);
	always_comb
		if(funct[1])
			RegWriteSrc = 2'b10; // Result
		else if(funct[2])
			RegWriteSrc = 2'b01; // ReadData
		else
			RegWriteSrc = 2'b00; // Imm
endmodule

module condcheck (input  logic[1:0] branchType,
						input  logic      negative, zero,
						output logic      condBranch);
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

module adder #(parameter WIDTH=8)
              (input  logic [WIDTH-1:0] a, b,
				   input  logic cin,
               output logic [WIDTH-1:0] y);
	assign y = a + b + cin;
endmodule

module regfile(input  logic       ph1, ph2, reset,
               input  logic       we3, 
               input  logic [3:0] ra1, ra2, wa3, 
               input  logic [7:0] wd3,
               output logic [7:0] rd1, rd2);
	// note: can't read PC in HMMM
	logic [7:0] rf[7:0];
	flopenr reg0(ph1, ph2, reset, we3&(wa3==4'd0), wd3, rf[0]);
	flopenr reg1(ph1, ph2, reset, we3&(wa3==4'd1), wd3, rf[1]);
	flopenr reg2(ph1, ph2, reset, we3&(wa3==4'd2), wd3, rf[2]);
	flopenr reg3(ph1, ph2, reset, we3&(wa3==4'd3), wd3, rf[3]);
	flopenr reg4(ph1, ph2, reset, we3&(wa3==4'd4), wd3, rf[4]);
	flopenr reg5(ph1, ph2, reset, we3&(wa3==4'd5), wd3, rf[5]);
	flopenr reg6(ph1, ph2, reset, we3&(wa3==4'd6), wd3, rf[6]);
	flopenr reg7(ph1, ph2, reset, we3&(wa3==4'd7), wd3, rf[7]);
	assign rd1 = rf[ra1];
	assign rd2 = rf[ra2];
endmodule

module mux2 #(parameter WIDTH = 8)
				 (input  logic [WIDTH-1:0] d0, d1, 
				  input  logic             s, 
				  output logic [WIDTH-1:0] y);
	assign y = s ? d1 : d0; 
endmodule

module mux3 #(parameter WIDTH = 8)
				 (input  logic [WIDTH-1:0] d0, d1, d2,
              input  logic [1:0]       s, 
              output logic [WIDTH-1:0] y);
	assign y = s[1] ? (s[0] ? 8'bx : d2) : (s[0] ? d1 : d0);
endmodule

module flop #(parameter WIDTH = 8)
				 (input  logic ph1, ph2, reset,
              input  logic [WIDTH-1:0] d, 
              output logic [WIDTH-1:0] q);
	logic[WIDTH-1:0] nextQ;
	always_latch
		if (ph1) q <= nextQ;
	always_latch
		if (ph2) nextQ <= d;
endmodule

module flopr #(parameter WIDTH = 8)
				  (input  logic ph1, ph2, reset,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);
	logic[WIDTH-1:0] nextQ;
	always_latch begin
		if (ph1)
			if (reset) q <= 0;
			else       q <= nextQ;
   end
	always_latch begin
		if (ph2)
			if (reset) nextQ <= 0;
			else       nextQ <= d;
	end
endmodule

module flopenr #(parameter WIDTH = 8)
                (input  logic ph1, ph2, reset, en,
                 input  logic [WIDTH-1:0] d, 
                 output logic [WIDTH-1:0] q);
	logic[WIDTH-1:0] nextQ;
	always_latch begin
		if (ph1)
			// if (reset)   q <= 0;
			if (en) q <= nextQ;
   end
	always_latch begin
		if (ph2)
			if (reset) nextQ <= 0;
			else       nextQ <= d;
	end
endmodule
