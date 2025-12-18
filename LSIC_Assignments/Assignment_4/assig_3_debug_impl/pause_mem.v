module pause_mem(
    input wire clk,
    input wire rst_n,
    input wire pause_detected, // Connect to the PAUSE state
    input wire next_saved,     // Connect to the NEXT button
    input wire idle_detected,  // High when in IDLE state
    // Inputs
    input wire [3:0] sec1_in, sec2_in, min1_in, min2_in,
    // Outputs
    output reg [3:0] sec1_out, sec2_out, min1_out, min2_out
);

    // Memory: 8 slots, 16 bits wide
    reg [15:0] memory [7:0];
    
    // Pointers
    reg [2:0] write_ptr;
    reg [2:0] read_ptr;

    // Edge Detection Registers
    reg pause_prev;
    reg next_prev;
    
    // Wires to detect the "rising edge" (moment of press)
    // NOT SURE ABT THIS ONE
    wire pause_edge = (pause_detected && !pause_prev);
    wire next_edge  = (next_saved && !next_prev);

    // Main Sequential Logic
    always @(posedge clk) begin
        if(!rst_n) begin
            write_ptr  <= 0;
            read_ptr   <= 0;
            pause_prev <= 0;
            next_prev  <= 0;
        end else begin
            // 1. Update Edge Detectors
            pause_prev <= pause_detected;
            next_prev  <= next_saved;

            // 2. WRITE LOGIC (Save Lap)
            // Only write if Pause button was JUST toggled ON
            if(pause_edge) begin
                memory[write_ptr] <= {min2_in, min1_in, sec2_in, sec1_in};
                write_ptr <= write_ptr + 1;
            end

            // 3. READ LOGIC (Browse Laps)
            if(idle_detected) begin
                if(next_edge) begin
                    read_ptr <= read_ptr + 1;
                end
                // Output the data at the current read pointer
                {min2_out, min1_out, sec2_out, sec1_out} <= memory[read_ptr];
            end 
            else begin
                read_ptr <= 0; 
                {min2_out, min1_out, sec2_out, sec1_out} <= {min2_in, min1_in, sec2_in, sec1_in};
            end
        end
    end

endmodule