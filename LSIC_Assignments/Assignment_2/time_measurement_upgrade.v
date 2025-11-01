// for Intel de10_lite implementation
module blinker_led(
    input wire clk,
    input wire rst_n,
    input wire start_stop,
    input wire pause,
    output reg [7:0] led
);

    //PARAMS
    parameter CLK_FREQ = 50_000_000; //50 MHz from the book
    parameter SECOND_COUNT = CLK_FREQ; // clock will trigger 50_000_000 times / second

    //INTERNAL SIGNALS
    reg [25:0] counter;
    reg [25:0] counter_next;
    reg [7:0] led_next;

    //STATE DEFINNITION
    localparam [1:0] 
        S_IDLE = 2'b00,
        S_RUN = 2'b01,
        S_PAUSE = 2'b10;

    reg [1:0] state, state_next;


    // SEQUENTIAL LOGIC
    always @(posedge clk) begin
        if(!rst_n) begin
            state <= S_IDLE;
            counter <= 0;
            led <= 0;
        end else begin
            state <= state_next;
            counter <= counter_next;
            led <= led_next;
        end
    end


    //COMBINATIONAL LOGIC
    always @(*) begin
        state_next = state;
        counter_next = counter;
        led_next = led;

        case (state)
            S_IDLE: begin
                counter_next = 0;
                led_next = 0;
                if(start_stop) begin
                    state_next = S_RUN;
                end
            end

            S_RUN: begin
                if(!start_stop) begin
                    state_next = S_IDLE;
                end
                else if (pause) begin
                    state_next = S_PAUSE;
                end
                else begin
                    if(counter == SECOND_COUNT - 1) begin
                        counter_next = 0;
                        led_next = led + 1;
                    end
                    else begin
                        counter_next = counter + 1;
                    end
                end
            end

            S_PAUSE: begin
                if(!start_stop) begin
                    state_next = S_IDLE;
                end
                else if(!pause) begin
                    state_next = S_RUN;
                end
                else begin
                    counter_next = counter;
                    led_next = led;
                end
            end
        endcase      
    end
endmodule