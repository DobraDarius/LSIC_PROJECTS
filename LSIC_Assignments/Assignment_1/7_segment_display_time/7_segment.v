// Millisecond Counter with 7-Segment Display
// Uses 4-digit display (HEX3-HEX0) to show milliseconds

module ms_counter_7seg (
    input wire clk,           // 50 MHz clock
    input wire rst_n,         // Active-low reset button
    output reg [6:0] HEX0,    // 7-segment display 0 (rightmost)
    output reg [6:0] HEX1,    // 7-segment display 1
    output reg [6:0] HEX2,    // 7-segment display 2
    output reg [6:0] HEX3,    // 7-segment display 3 (leftmost)
    output reg [9:0] LEDR     // LEDs for visual feedback
);


    // PARAMETERS
    parameter CLK_FREQ = 50_000_000;  // 50 MHz
    parameter MS_DIVIDER = CLK_FREQ / 1000;  // 50,000 counts = 1ms
    

    // INTERNAL SIGNALS
    reg [15:0] clk_counter;      // Counts clock cycles
    reg [15:0] clk_counter_next; // Next state
    reg [15:0] ms_count;         // Millisecond counter (0 to 9999)
    reg [15:0] ms_count_next;    // Next state

    
    // BCD digits for 7-segment display
    wire [3:0] thousands;  // Thousands digit
    wire [3:0] hundreds;   // Hundreds digit
    wire [3:0] tens;       // Tens digit
    wire [3:0] ones;       // Ones digit

    
    // ALWAYS BLOCK 1: SEQUENTIAL (STATE REGISTERS)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // RESET: Clear all counters
            clk_counter <= 0;
            ms_count <= 0;
            LEDR <= 0;
        end else begin
            // NORMAL: Update with next values
            clk_counter <= clk_counter_next;
            ms_count <= ms_count_next;
            LEDR <= ms_count_next[9:0]; // Show on LEDs too
        end
    end
    
    
    // ALWAYS BLOCK 2: COMBINATIONAL (NEXT STATE LOGIC)
    always @(*) begin
        // DEFAULT: Keep current values
        clk_counter_next = clk_counter;
        ms_count_next = ms_count;
        
        if (clk_counter == (MS_DIVIDER - 1)) begin
            // 1ms reached
            clk_counter_next = 0;
            if (ms_count == 9999) 
                ms_count_next = 0;  // Reset at 9999 ms
            else
                ms_count_next = ms_count + 1;
        end else begin
            // Still counting toward 1ms
            clk_counter_next = clk_counter + 1;
        end
    end
    
    // BINARY TO BCD CONVERSION
    assign thousands = (ms_count / 1000) % 10;
    assign hundreds  = (ms_count / 100) % 10;
    assign tens      = (ms_count / 10) % 10;
    assign ones      = ms_count % 10;
    
    // 7-SEGMENT DECODERS (COMMON ANODE)
    // 0 = segment ON, 1 = segment OFF
    
    // HEX0 - Ones digit (rightmost)
    always @(*) begin
        case (ones)
            4'h0: HEX0 = 7'b1000000;  // 0
            4'h1: HEX0 = 7'b1111001;  // 1
            4'h2: HEX0 = 7'b0100100;  // 2
            4'h3: HEX0 = 7'b0110000;  // 3
            4'h4: HEX0 = 7'b0011001;  // 4
            4'h5: HEX0 = 7'b0010010;  // 5
            4'h6: HEX0 = 7'b0000010;  // 6
            4'h7: HEX0 = 7'b1111000;  // 7
            4'h8: HEX0 = 7'b0000000;  // 8
            4'h9: HEX0 = 7'b0010000;  // 9
            default: HEX0 = 7'b1111111; // off
        endcase
    end
    
    // HEX1 - Tens digit
    always @(*) begin
        case (tens)
            4'h0: HEX1 = 7'b1000000;  // 0
            4'h1: HEX1 = 7'b1111001;  // 1
            4'h2: HEX1 = 7'b0100100;  // 2
            4'h3: HEX1 = 7'b0110000;  // 3
            4'h4: HEX1 = 7'b0011001;  // 4
            4'h5: HEX1 = 7'b0010010;  // 5
            4'h6: HEX1 = 7'b0000010;  // 6
            4'h7: HEX1 = 7'b1111000;  // 7
            4'h8: HEX1 = 7'b0000000;  // 8
            4'h9: HEX1 = 7'b0010000;  // 9
            default: HEX1 = 7'b1111111; // off
        endcase
    end
    
    // HEX2 - Hundreds digit
    always @(*) begin
        case (hundreds)
            4'h0: HEX2 = 7'b1000000;  // 0
            4'h1: HEX2 = 7'b1111001;  // 1
            4'h2: HEX2 = 7'b0100100;  // 2
            4'h3: HEX2 = 7'b0110000;  // 3
            4'h4: HEX2 = 7'b0011001;  // 4
            4'h5: HEX2 = 7'b0010010;  // 5
            4'h6: HEX2 = 7'b0000010;  // 6
            4'h7: HEX2 = 7'b1111000;  // 7
            4'h8: HEX2 = 7'b0000000;  // 8
            4'h9: HEX2 = 7'b0010000;  // 9
            default: HEX2 = 7'b1111111; // off
        endcase
    end
    
    // HEX3 - Thousands digit (leftmost)
    always @(*) begin
        case (thousands)
            4'h0: HEX3 = 7'b1000000;  // 0
            4'h1: HEX3 = 7'b1111001;  // 1
            4'h2: HEX3 = 7'b0100100;  // 2
            4'h3: HEX3 = 7'b0110000;  // 3
            4'h4: HEX3 = 7'b0011001;  // 4
            4'h5: HEX3 = 7'b0010010;  // 5
            4'h6: HEX3 = 7'b0000010;  // 6
            4'h7: HEX3 = 7'b1111000;  // 7
            4'h8: HEX3 = 7'b0000000;  // 8
            4'h9: HEX3 = 7'b0010000;  // 9
            default: HEX3 = 7'b1111111; // off
        endcase
    end

endmodule;