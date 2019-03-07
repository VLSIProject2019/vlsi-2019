// Generic SRAM for E190AT: VLSI Design Project
// Authors: Erik Meike, Dominique Mena, Caleb Norfleet, & Kaveh Pezeshki
// Created Spring 2019

module sram #(
							parameter ADDR_WIDTH=16;
							parameter DATA_WIDTH=16;
						 )
					 	(
							input logic ce,    // Active low chip enable
							input logic oe,    // Active low output enable
							input logic we,    // Active low write enable

							input logic [ADDR_WIDTH-1:0] adr,  // Address bus
							inout logic [DATA_WIDTH-1:0] data  // Data bus		
					 	);

					 	// internal variables
					 	reg [DATA_WIDTH-1:0] data_out;            // caching requested data
					 	reg [DATA_WIDTH-1:0] mem [ADDR_WITH-1:0]; // memory

					 	// Combinational logic
					 	always_comb
							if (!ce && we && !oe) data = data_out;
							else                  data = DATA_WIDTH'bz;

					 	// Memory Read / Write Latches
						always_latch
						begin:
							if (!cs && !we && oe) // if writing data
								mem[adr] = data;
							if (!cs && we && !oe) //if reading data
								data_out = mem[adr];
						end

						// Initial block to set up memory for testing
						initial
							$readmemh("memfile.dat", mem);
endmodule

							
	 				 	


