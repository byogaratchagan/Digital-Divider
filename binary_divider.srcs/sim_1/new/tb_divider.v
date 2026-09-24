`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2026 09:45:59 AM
// Design Name: 
// Module Name: tb_divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module tb_divider;

    // Inputs
    reg [32:0] dividend;
    reg [32:0] divisor;
    reg clk;
    reg start;
    reg reset;
    
    reg stop_clk; 

    // Outputs
    wire [32:0] q;
    wire done;

    // Instantiate the Unit Under Test (UUT)
    divider uut (
        .dividend(dividend),
        .divisor(divisor),
        .clk(clk),
        .start(start),
        .reset(reset),
        .q(q),
        .done(done)
    );

    // Clock generation (20 time units period)
    always #10 begin
        if (done) begin
            stop_clk = 1; 
        end
        if (!stop_clk) begin 
            clk = ~clk;
        end
    end 

    initial begin
        // Initialize Inputs
        reset = 0;
        stop_clk = 1;
        clk = 0;
        dividend = ~0; 
        divisor = 8'b11;
        start = 1;
        #10
        start = 1;
        clk = 1;
        #10;
        start = 0;
        clk = 0;
        #10;
        stop_clk = 0; 

        // Allow the simulation to run for enough clock cycles 
        // to see the sequential logic and $display outputs
        #20000;
        
        // Stop the simulation
        $finish;
    end
endmodule
