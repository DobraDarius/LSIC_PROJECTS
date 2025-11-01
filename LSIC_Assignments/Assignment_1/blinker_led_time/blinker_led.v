// for Intel de10_lite implementation
// led will blink to count a second -> half second open, half second closed

module blinker_led(
    input wire clk,
    input wire rst_n,
    output reg led
);

    //PARAMS
    parameter CLK_FREQ = 50_000_000; //50 MHz from the book
    parameter SECOND_COUNT = CLK_FREQ; // clock will trigger 50_000_000 times / second

    //INTERNAL SIGNALS
    reg [25:0] counter;
    reg [25:0] counter_next;
    reg led_next;


    // SEQUENTIAL LOGIC
    always @(posedge clk) begin
        if(!rst_n) begin
            counter <= 0;
            led <= 0;
        end else begin
            counter <= counter_next;
            led <= led_next;
        end
    end


    //COMBINATIONAL LOGIC
    always @(*) begin
        counter_next = counter;
        led_next = led;

        if(counter == (SECOND_COUNT - 1)) begin
            counter_next = 0;
            led_next = ~led;
        end else begin
            counter_next = counter + 1;
        end
    end
endmodule