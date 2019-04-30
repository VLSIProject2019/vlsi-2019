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
	logic test_extra, test_out, test_in;
        assign test_in = 1'b1;
	chip dut(Adr, MemWrite, test_extra, test_out, MemData[14:0], clk1, clk2, reset, test_in);

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

