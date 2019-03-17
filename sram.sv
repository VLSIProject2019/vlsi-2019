// Generic SRAM for E190AT: VLSI Design Project
// Authors: Erik Meike, Dominique Mena, Caleb Norfleet, & Kaveh Pezeshki
// Created Spring 2019

module sram #(
							parameter ADDR_WIDTH=16,
							parameter DATA_WIDTH=16
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
					 	reg [DATA_WIDTH-1:0] mem [ADDR_WIDTH-1:0]; // memory

					 	// Combinational logic: memory read tri-state
						assign data = (!ce && we && !oe) ? data_out : {(DATA_WIDTH){1'bz}};

					 	// Memory Read / Write Latches
						always_latch
							if (!ce && !we && oe) // if writing data
								mem[adr] = data;
							else if (!ce && we && !oe) //if reading data
								data_out = mem[adr];

						// Initial block to set up memory for testing
						initial
							$readmemh("memfile.dat", mem);
endmodule

							
	 				 	


