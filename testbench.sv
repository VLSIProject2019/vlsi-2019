// Microprocessor Testbench for E190AT: VLSI Design Project
// Authors: Erik Meike, Dominique Mena, Caleb Norfleet, & Kaveh Pezeshki
// Created Spring 2019

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
		clk2 = 0; reset = 1; #22; reset = 0;
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
		//Insert condition here (similar to Lab 10/11, need instructions first)
	end
endmodule
