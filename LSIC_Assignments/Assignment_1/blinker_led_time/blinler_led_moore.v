// Moore FSM implementation for 1-second LED blinker
module blinker_led(
    input wire clk,
    input wire rst_n,
    output reg led
);

    // PARAMETERS
    parameter CLK_FREQ = 50_000_000;
    parameter ONE_SECOND = CLK_FREQ;
    
    // FSM STATES
    localparam STATE_LED_OFF = 1'b0;
    localparam STATE_LED_ON  = 1'b1;
    
    // INTERNAL SIGNALS
    reg [25:0] counter;
    reg [25:0] counter_next;
    reg current_state;
    reg next_state;

    // SEQUENTIAL LOGIC
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            current_state <= STATE_LED_OFF;
            led <= 1'b0;  // Start with LED OFF
        end else begin
            counter <= counter_next;
            current_state <= next_state;
            
            // Moore output - depends only on current state
            case (current_state)
                STATE_LED_OFF: led <= 1'b0;
                STATE_LED_ON:  led <= 1'b1;
                default:       led <= 1'b0;
            endcase
        end
    end

    // COMBINATIONAL LOGIC
    always @(*) begin
        // Default assignments
        counter_next = counter;
        next_state = current_state;
        
        case (current_state)
            STATE_LED_OFF: begin
                if (counter == (ONE_SECOND - 1)) begin
                    counter_next = 0;
                    next_state = STATE_LED_ON;  // Switch to ON state
                end else begin
                    counter_next = counter + 1;
                end
            end
            
            STATE_LED_ON: begin
                if (counter == (ONE_SECOND - 1)) begin
                    counter_next = 0;
                    next_state = STATE_LED_OFF; // Switch to OFF state
                end else begin
                    counter_next = counter + 1;
                end
            end
            
            default: begin
                counter_next = 0;
                next_state = STATE_LED_OFF;
            end
        endcase
    end

endmodule