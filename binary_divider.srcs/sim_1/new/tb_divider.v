`timescale 1ns / 1ps

module tb_divider;
    
    integer clock_count;
    reg [31:0] dividend;
    reg [31:0] divisor;
    reg clk;
    reg start;
    reg reset;
    
    reg stop_clk; 

    wire [31:0] q;
    wire done;

    divider dut (
        .dividend(dividend),
        .divisor(divisor),
        .clk(clk),
        .start(start),
        .reset(reset),
        .q(q),
        .done(done)
    );

    always #1 begin
        if (done) begin
            if (stop_clk == 0) $display("Total clock cycle: %d", clock_count/2);
            stop_clk = 1;
        end
        if (!stop_clk) begin 
            clk = ~clk;
            clock_count = clock_count + 1;
        end
    end 

    initial begin
        clock_count = 0;
        stop_clk = 1;
        clk = 1;
        reset = 1;
        start = 0;
        dividend = 0;
        divisor = 0;
        # 1;
        reset = 0;
        clk = 0;
        dividend = ~0;  // try for different values to test 
        divisor = 8'b111; // try for different value to test.
        start = 1;
        #1
        start = 1;
        clk = 1;
        #1;
        start = 0;
        clk = 0;
        #1;
        stop_clk = 0; 

        #200000;

        $finish;
    end
endmodule
