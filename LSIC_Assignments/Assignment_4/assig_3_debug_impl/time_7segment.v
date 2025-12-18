module time_7segment(
	input wire clk,
	input wire rst_n,
	input wire start_stop,
	input wire pause,
    input wire next_saved,
	output reg [1:0]debug_leds,
	output wire [6:0] segment_1, segment_2, segment_3, segment_4,
    output reg dot,
    output [1:0] switch
);

	assign switch = {start_stop, pause};

	//PARAMS
    parameter CLK_FREQ = 50_000_000; //50 MHz from the book
    parameter SECOND_COUNT = CLK_FREQ; // clock will trigger 50_000_000 times / second
    
    //INTERNAL_SIGNALS
    reg [25:0] counter;
    reg [25:0] counter_next;
    reg [3:0] second_counter_1;
    reg [3:0] second_counter_next_1;
    reg [3:0] second_counter_2;
    reg [3:0] second_counter_next_2;
    reg [3:0] minute_counter_1;
    reg [3:0] minute_counter_next_1;
    reg [3:0] minute_counter_2;
    reg [3:0] minute_counter_next_2;

    //STATE DEFINNITION
    localparam [1:0] S_IDLE = 2'b00;
    localparam [1:0] S_RUN = 2'b01;
    localparam [1:0] S_PAUSE = 2'b10;

    // Pause counter
    localparam [3:0] pause_cnt;

    reg [1:0] state, state_next;


    // SEQUENTIAL LOGIC
    always @(posedge clk) begin
        if(!rst_n) begin
            state <= S_IDLE;
            pause_cnt <= 0;
            counter <= 0;
            second_counter_1 <= 0;
            second_counter_2 <= 0;
            minute_counter_1 <= 0;
            minute_counter_2 <= 0;
            dot <= 1;
            debug_leds <= state;
        end else begin
            state <= state_next;
            counter <= counter_next;
            second_counter_1 <= second_counter_next_1;
            second_counter_2 <= second_counter_next_2;
            minute_counter_1 <= minute_counter_next_1;
            minute_counter_2 <= minute_counter_next_2;
            dot <= 0;
            debug_leds <= state;
        end
    end

    //COMBINATIONAL BLOCK
     always @(*) begin
        state_next = state;
        counter_next = counter;
        second_counter_next_1 = second_counter_1;
        second_counter_next_2 = second_counter_2;
        minute_counter_next_1 = minute_counter_1;
        minute_counter_next_2 = minute_counter_2;
        pause_cnt = pause_cnt;

        case (state)
            S_IDLE: begin
                counter_next = 0;
                second_counter_next_1 = 0;
                second_counter_next_2 = 0;
                minute_counter_next_1 = 0;
                minute_counter_next_2 = 0;
				
                if(start_stop && !pause) begin
                    state_next = S_RUN;
                end
            end

            S_RUN: begin
                // when we restart, pause counter goes to 0
                pause_cnt = 0;
                if(pause) begin
                    state_next = S_PAUSE;
                end
                else if (!start_stop) begin
                    state_next = S_IDLE;
                end
                else begin
                    if(counter == SECOND_COUNT - 1) begin
                        counter_next = 0;

                        if(second_counter_1 == 9) begin
                            second_counter_next_1 = 0;

                            if(second_counter_2 == 5) begin
                                second_counter_next_2 = 0;

                                if(minute_counter_1 == 9) begin
                                    minute_counter_next_1 = 0;

                                    if(minute_counter_2 == 5) begin
                                        minute_counter_next_2 = 0;
                                    end
                                    else begin
                                        minute_counter_next_2 = minute_counter_2 + 1;
                                    end
                                end
                                else begin
                                    minute_counter_next_1 = minute_counter_1 + 1;
                                end
                            end
                            else begin
                                second_counter_next_2 = second_counter_2 + 1;
                            end
                        end
                        else begin
                            second_counter_next_1 = second_counter_1 + 1;
                        end
                    end
                    else begin
                        counter_next = counter + 1;
                    end
                end
            end

            S_PAUSE: begin
                // increment the pause counter
                pause_cnt = pause_cnt + 1;
                if(!start_stop) begin
                    state_next = S_IDLE;
                end
                else if(!pause) begin
                    state_next = S_RUN;
                end
                else begin
                    state_next = S_PAUSE;
                end
            end

            default: state_next = S_IDLE;
        endcase      
    end

    decoder sec_block_1(
        .inp (second_counter_1),
        .out (segment_1)
    );
    
    decoder sec_block_2(
        .inp (second_counter_2),
        .out (segment_2)
    );

    decoder min_block_1(
        .inp (minute_counter_1),
        .out (segment_3)
    );

    decoder min_block_2(
        .inp (minute_counter_2),
        .out (segment_4)
    );

endmodule
