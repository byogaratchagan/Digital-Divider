`timescale 1ns / 1ps

module divider #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] dividend,
    input  wire [WIDTH-1:0] divisor,
    input  wire clk,
    input  wire start,
    input  wire reset,
    
    output wire [WIDTH-1:0] q,
    output wire done
);

    reg [WIDTH-1:0] an;
    reg [WIDTH-1:0] bn;
    reg [WIDTH-1:0] partial_q;
    

    reg [1:0] state; 
    reg done_reg;
    reg add_sub;

    reg [5:0] shift_amt_reg;
    reg [WIDTH-1:0] extract_reg;
    reg [WIDTH-1:0] lower_an_reg;
    
    integer i;
    integer msb;
    integer no_bits;
    integer power_pos;
    reg [1:0] found2;
    reg found, found1;
    reg power_of2;

    assign q = partial_q;
    assign done = done_reg;

    always @(*) begin
        found = 1'b0;
        found1 = 1'b0;
        found2 = 2'b11;
        msb = 0;
        no_bits = 0;
        power_pos = 0;
        
        for (i = WIDTH-1; i >= 0; i = i - 1) begin
            if (!found && an[i]) begin
                msb = i;
                found = 1'b1;
            end
            if (!found1 && bn[i]) begin
                no_bits = i;
                found1 = 1'b1;
            end 
            
            if (found2 == 2'b11 && bn[i]) begin
                found2 = 2'b01;
                power_pos = i;
            end
            else if (found2 == 2'b01 && bn[i]) begin
                found2 = 2'b00;
            end
        end
        
        power_of2 = (found2 == 2'b01);
    end

    wire [5:0] shift_amt = (msb >= no_bits) ? (msb - no_bits) : 6'd0;
    wire [WIDTH-1:0] extract = an >> shift_amt;
    wire [WIDTH-1:0] lower_an = an & ((1 << shift_amt) - 1);

    always @(posedge clk) begin
        if (reset) begin
            an <= 0;
            bn <= 0;
            state <= 2'b00;
            partial_q <= 0;
            done_reg <= 1'b0;
            add_sub <= 1'b0;
            shift_amt_reg <= 0;
            extract_reg <= 0;
            lower_an_reg <= 0;
        end 
        else begin
            case (state)
                2'b00: begin // IDLE
                    done_reg <= 1'b0;
                    if (start) begin
                        an <= dividend;
                        bn <= divisor;
                        partial_q <= 0;
                        add_sub <= 1'b0;
                        state <= 2'b01;
                    end
                end

                2'b01: begin 
                    if (power_of2) begin
                        partial_q <= (an >> power_pos);
                        state <= 2'b00;
                        done_reg <= 1'b1;
                    end
                    else if (an >= bn) begin
                        shift_amt_reg <= shift_amt;
                        extract_reg <= extract;
                        lower_an_reg <= lower_an;
                        state <= 2'b10;
                    end
                    else begin
                        state     <= 2'b00;
                        done_reg  <= 1'b1;
                    end
                end
                
                2'b10: begin 
                    if (!add_sub)
                        partial_q <= partial_q + (1 << shift_amt_reg);
                    else
                        partial_q <= partial_q - (1 << shift_amt_reg);

                    if (extract_reg >= bn) begin 
                        an <= ((extract_reg - bn) << (shift_amt_reg > 0 ? shift_amt_reg - 1 : 0)) + lower_an_reg;
                        add_sub <= 1'b0;
                    end 
                    else begin
                        an <= ((bn - extract_reg) << (shift_amt_reg > 0 ? shift_amt_reg - 1 : 0)) + lower_an_reg;
                        add_sub <= 1'b1;
                    end
                    
                    state <= 2'b01; 
                end
                
                default: state <= 2'b00;
            endcase
        end
    end

endmodule