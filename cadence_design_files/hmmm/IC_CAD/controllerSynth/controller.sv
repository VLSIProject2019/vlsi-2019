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
