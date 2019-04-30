// Microprocessor Testbench for E190AT: VLSI Design Project
// Authors: Erik Meike, Dominique Mena, Caleb Norfleet, & Kaveh Pezeshki
// Created Spring 2019


// Set delay unit to 1 ns and simulation precision to 0.1 ns (100 ps)
`timescale 1ns / 100ps


module testbench();
	
	// Processor signals
   logic  clk1, clk2;
   logic  reset;
	
	// Memory interface
	logic        MemWrite; // active high
	wire  [15:0] MemData;
   logic [7:0]  Adr;
	
	// Internal Signals and Combinational Logic
	// To be handled on PCB
	
	// SRAM interface
	logic ce; // chip enable, active low
	logic oe; // output enable, active low
	logic we; // write enable, active low

	assign ce = 1'b0;
	assign oe = MemWrite; // output enabled when not writing
	assign we = !MemWrite;
	
	// Instantiating the processor
   top dut(clk1, clk2, reset, MemWrite, Adr, MemData[14:8], MemData[7:0]);

	// Instantiating the SRAM
	sram mem(ce, oe, we, Adr, MemData);

	// Opening the testvector file and setting up memory
	// Pulsing reset to initialize the processor
	initial
	begin
		// NOTE: sram module automatically initializes memory
		// from memfile.dat
		clk2 = 0; reset = 1; #19; reset = 0;
	end

	// Creating the clock
	always
	begin
		clk1 <= 1; # 3; clk1 <= 0; # 2;
		clk2 <= 1; # 3; clk2 <= 0; # 2;
	end
	
	// Executing Instructions
	always @(negedge clk2) 
	begin
		if(MemWrite) begin
			if(MemData === 16'bzzzzzzzz00101101) // && dut.dp.PC === 8'd32)
				$display("Test Successful!");
			else
				$display("Test Failed with MemData = %b", MemData);
				//$display("Test Failed on Line %d with MemData = %b", dut.dp.PC, MemData);
			$stop;
		end
	end
endmodule

// Generic SRAM for E190AT: VLSI Design Project
// Authors: Erik Meike, Dominique Mena, Caleb Norfleet, & Kaveh Pezeshki
// Created Spring 2019

module sram #(parameter ADDR_WIDTH=8,
				  parameter DATA_WIDTH=16)
				(
					input logic ce,    // Active low chip enable
					input logic oe,    // Active low output enable
					input logic we,    // Active low write enable
					
					input logic [ADDR_WIDTH-1:0] adr,  // Address bus
					inout wire  [DATA_WIDTH-1:0] data  // Data bus
				);
	
	// internal variables
	reg  [DATA_WIDTH-1:0] data_out;   // caching requested data
	reg  [DATA_WIDTH-1:0] mem [(ADDR_WIDTH**2)-1:0]; // memory

	// Combinational logic: memory read tri-state
	assign data = (!ce && we && !oe) ? data_out : {(DATA_WIDTH){1'bz}};

	// Memory Read / Write Latches
	always_latch
		if (!ce && !we && oe) // if writing data
			mem[adr] = data;
		else if (!ce && we && !oe) //if reading data
			data_out = mem[adr];

	// Initial block to set up memory for testing
	initial begin
		$readmemb("memfile.dat", mem);
	end
endmodule

// Microprocessor for E190AT: VLSI Design Project
// Authors: Erik Meike, Caleb Norfleet, & Kaveh Pezeshki
// Created Spring 2019

module top (input  logic        ph1, ph2, reset,
				output logic        MemWrite,
				output logic [7:0]  Adr,
				input  logic [14:8] MemData1,
				inout  logic [7:0]  MemData2);
	
	logic PCEnable, AdrSrc, RA1Src, InstrSrc, RegWrite;
	logic TwoRegs, ALUSub, negative, zero, RegWLoadSrc;
	logic [1:0]  PCSrc, RegWriteSrc;
	logic [7:0]  WriteData;
	logic [14:8] instr1;
	
	// tristate for handling write data
	assign MemData2[7:0]  = (MemWrite ? WriteData : 8'bz);
	
	controller c(ph1, ph2, reset, negative, zero, RegWLoadSrc,
					 RA1Src, PCEnable, AdrSrc, InstrSrc, RegWrite,
					 TwoRegs, ALUSub, PCSrc, RegWriteSrc, MemWrite,
					 MemData1, instr1);
	
	//datapath dp(Adr, negative, zero, MemData2[7:0], ALUSub,
	//	    AdrSrc, instr1[10:8], InstrSrc, MemWrite,
	//	    PCEnable, PCSrc, RA1Src, RegWLoadSrc, RegWrite,
	//	    RegWriteSrc, TwoRegs, ph1, ph2, reset );
	
	datapath dp(ph1, ph2, reset, PCEnable, AdrSrc, InstrSrc,
					RA1Src, RegWrite, MemWrite, TwoRegs, ALUSub, RegWLoadSrc,
					PCSrc, RegWriteSrc, instr1[10:8], MemData2, WriteData,
					Adr, negative, zero);
endmodule

module datapath (input  logic        ph1, ph2, reset,
					  input  logic        PCEnable, AdrSrc, InstrSrc, RA1Src, RegWrite,
					  input  logic        MemWrite, TwoRegs, ALUSub, RegWLoadSrc,
					  input  logic [1:0]  PCSrc, RegWriteSrc,
					  input  logic [10:8] instr1,
					  input  logic [7:0]  MemData2,
					  output logic [7:0]  WriteData,
					  output logic [7:0]  Adr,
					  output logic        negative, zero);
	
	logic[7:0]  PC, PCNext, PCPlus1;
	logic[7:0]  Result, SrcA, SrcB, Imm, WD3;
	logic[7:0]  WD3Temp, WD3Temp2, RD1, RD2;
	logic[2:0]  RA1, RA2, WA3;
	logic[7:0]  instrTemp2, instr2;
	
	// next PC logic
	adder   #(8) pcAdd(PC, 8'b1, 1'b0, PCPlus1);
	flopenr #(8) pcReg(ph1, ph2, reset, PCEnable, PCNext, PC);
	mux3    #(8) pcMux(PCPlus1, Imm, RD1, PCSrc, PCNext);
	
	// data memory
	mux2 #(8) adrMux(PC, RD2, AdrSrc, Adr);
	assign WriteData = RD1;
	
	// instruction handling
	flopr #(8) instrReg2(ph1, ph2, reset, MemData2, instrTemp2);
	mux2  #(8) instrMux2(instrTemp2, MemData2, InstrSrc, instr2);
	
	// register read/write logic
	mux3 #(8) wd3Mux(Imm, MemData2[7:0], Result, RegWriteSrc, WD3Temp);
	flop #(8) wd3Reg(ph1, ph2, reset, WD3Temp, WD3Temp2);
	mux2 #(8) loadMux(WD3Temp2, WD3Temp, RegWLoadSrc, WD3);
	regfile   rf(ph1, ph2, reset, RegWrite, RA1, RA2, WA3, WD3, RD1, RD2);
	mux2 #(3) ra1Mux(instr2[7:5], instr1[10:8], RA1Src, RA1);
	assign RA2 = instr2[4:2];
	assign WA3 = instr1[10:8];
	assign Imm = instr2[7:0];
	
	// zero and negative for conditional branching
	assign negative = RD1[7];
	assign zero = ~(|RD1);
	
	// ALU logic
	assign SrcB = {8{ALUSub}} ^ RD2;
	// ^same as: mux2  #(8) srcBMux(RD2, notRD2, ALUSub, SrcB);
	assign SrcA = {8{TwoRegs}} & RD1;
	// ^same as: mux2  #(8) srcAMux(8'b0, RD1, TwoRegs, SrcA);
	adder #(8) alu(SrcA, SrcB, ALUSub, Result);
endmodule//*/

module controller (input  logic       ph1, ph2, reset,
						 input  logic       negative, zero,
						 output logic       RegWLoadSrc, RA1Src, PCEnable, AdrSrc,
					    output logic       InstrSrc, RegWrite, TwoRegs, ALUSub,
					    output logic[1:0]  PCSrc, RegWriteSrc,
						 output logic       MemWrite,
						 input  logic[14:8] MemData1,
						 output logic[14:8] instr1);
	logic state, stateBar, condBranch;
	logic branch, unconditional, regJumpLoc;
	logic[3:0] funct;
	logic[14:8] instrTemp1;
	
	// instruction handling
	flopr #(7) instrReg1(ph1, ph2, reset, MemData1, instrTemp1);
	mux2  #(7) instrMux1(instrTemp1, MemData1, InstrSrc, instr1);
	assign funct = instr1[14:11];
	
	// cycle clock "FSM" (0=instr read, 1=load/write back)
	// note: branch instructions only require one cycle
	flopr #(1) stateReg(ph1, ph2, reset, stateBar & ~branch, state);
	assign stateBar = ~state;
	
	assign PCEnable = state | branch;
	assign AdrSrc   = state;
	assign InstrSrc = ~reset & stateBar;
	
	// branch
	assign branch        = funct[3];
	assign unconditional = funct[2];
	assign regJumpLoc    = funct[1];
	condcheck cc(funct[1:0], negative, zero, condBranch);
	assign PCSrc = (branch & (unconditional | condBranch)) ?
						((unconditional & regJumpLoc) ?
						2'b10 : 2'b01) : 2'b00;
	assign RA1Src = branch;
	
	// data processing
	assign TwoRegs = funct[1];
	assign ALUSub  = funct[0];
	
	// writeback
	assign MemWrite = (state & (funct == 4'b0010)) & ~reset;
	// ^Note: added &~reset so that first instruction can be loaded at init
	assign RegWrite = state & ~branch & (funct[2] | funct[0]);
	always_comb
		if(funct[2])
			RegWriteSrc = 2'b10; // Result
		else if(funct[1])
			RegWriteSrc = 2'b01; // ReadData
		else
			RegWriteSrc = 2'b00; // Imm
	assign RegWLoadSrc = (funct == 4'b0011);
endmodule

module condcheck (input  logic[1:0] branchType,
						input  logic      negative, zero,
						output logic      condBranch);
	always_comb
		case(branchType) // branchType = {isZero, greaterThan}
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

// note: regfile copied from MIPS8 design
module regfile #(parameter WIDTH = 8)
                (input  logic     ph1, ph2, reset,
                 input  logic     we3,
                 input  logic [2:0] ra1, ra2, wa3,
                 input  logic [WIDTH-1:0] wd3,
                 output logic [WIDTH-1:0] rd1, rd2);
					  
	// note: can't read PC in HMMM
   // three ported register file
   // read two ports combinationally
   // write third port during phase2 (second half-cycle)
	
   logic [WIDTH-1:0] RAM [7:0];
	
   always_latch
		if (ph2 & we3) RAM[wa3] <= wd3;

	assign rd1 = RAM[ra1];
	assign rd2 = RAM[ra2];
endmodule//*/

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
	// note: 11 is treated as the same as 10
	assign y = s[1] ? (d2) : (s[0] ? d1 : d0);
	// alternative:
	// assign y = s[1] ? (s[0] ? 8'bx : d2) : (s[0] ? d1 : d0);
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

// taken from MIPS8
module flopr #(parameter WIDTH = 8)
				  (input  logic ph1, ph2, reset,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);
	logic[WIDTH-1:0] nextQ;
	always_latch begin
		if (ph1)
			q <= nextQ;
   end
	always_latch begin
		if (ph2)
			if (reset) nextQ <= 0;
			else       nextQ <= d;
	end
endmodule

// taken from MIPS8
module flopenr #(parameter WIDTH = 8)
                (input  logic ph1, ph2, reset, en,
                 input  logic [WIDTH-1:0] d, 
                 output logic [WIDTH-1:0] q);
	logic [WIDTH-1:0] d2, resetval;
	assign resetval = 0;
	
	mux3 #(WIDTH) enrmux(q, d, resetval, {reset, en}, d2);
	flop #(WIDTH) f(ph1, ph2, reset, d2, q);
endmodule
