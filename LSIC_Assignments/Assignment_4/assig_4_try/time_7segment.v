module time_7segment(
	input wire clk,
	input wire rst_n,
	input wire start_stop,
	input wire pause,
    input wire next_saved,
	output reg [2:0] debug_leds,
	output wire [6:0] segment_1, segment_2, segment_3, segment_4,
    output reg dot,
    output [2:0] switch
);

	assign switch = {start_stop, pause, next_saved};

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
    localparam [2:0] S_IDLE = 3'b000;
    localparam [2:0] S_RUN = 3'b001;
    localparam [2:0] S_PAUSE = 3'b010;
    localparam [2:0] S_READ = 3'b011;
    localparam [2:0] S_READ_NXT = 3'b100;

    // track the write and read
    reg [7:0] wr_pnt, rd_pnt, wr_pnt_next, rd_pnt_next;
    
    // States mapped
    reg [2:0] state, state_next;

    //the data from the memory need to be "captured"
    wire [15:0] mem_data_out;

    //memory declaration
    sram_2port memory(
        .clk (clk),
        .rd_data (mem_data_out),
        .rd_addr (rd_pnt),
        .rd_en (state == S_READ || state == S_READ_NXT), //only in reading states 
        .wr_data({minute_counter_2, minute_counter_1, second_counter_2, second_counter_1}),
        .wr_addr (wr_pnt),
        .wr_en (state == S_RUN && pause) // on the edge going to pause
    );


    // SEQUENTIAL LOGIC
    always @(posedge clk) begin
        if(!rst_n) begin
            state <= S_IDLE;
            wr_pnt <= 0;
            rd_pnt <= 0;
            counter <= 0;
            second_counter_1 <= 0;
            second_counter_2 <= 0;
            minute_counter_1 <= 0;
            minute_counter_2 <= 0;
            dot <= 1;
            debug_leds <= state;
        end else begin
            state <= state_next;
            wr_pnt <= wr_pnt_next;
            rd_pnt <= rd_pnt_next;
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
        wr_pnt_next = wr_pnt;
        rd_pnt_next = rd_pnt; 

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
                if(pause) begin
                	wr_pnt_next = wr_pnt + 1;
                	
                    state_next = S_PAUSE;
                end
                else if (!start_stop) begin
                	if(wr_pnt > 0) begin
                		state_next = S_READ;
                	end
                	else begin
                    	state_next = S_IDLE;
                    end
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
            	
                if(!start_stop) begin
                    state_next = S_READ;
                end
                else if(!pause) begin
                    state_next = S_RUN;
                end
                else begin
                    state_next = S_PAUSE;
                end
            end
            
            S_READ: begin
            	if(rd_pnt == wr_pnt) begin
            		state_next = S_IDLE;
            	end
            	else if(next_saved) begin
            		state_next = S_READ_NXT;
            	end 
            end
           
           	S_READ_NXT: begin
           		if(!next_saved) begin
           			rd_pnt_next = rd_pnt + 1;
           			state_next = S_READ;
           		end
            end
           			
            default: state_next = S_IDLE;
        endcase      
    end

    // Create a selection for displayed values(MUX)

    // the "JARS" where the propper values will be stored
    reg [3:0] display_val_sec1, display_val_sec2, display_val_min1, display_val_min2;

    //the MUX logic
    always @(*) begin
        if(state == S_READ || state == S_READ_NXT) begin
            display_val_sec1 = mem_data_out[3:0];
            display_val_sec2 = mem_data_out[7:4];
            display_val_min1 = mem_data_out[11:8];
            display_val_min2 = mem_data_out[15:12];
        end
        else begin
            display_val_sec1 = second_counter_1;
            display_val_sec2 = second_counter_2;
            display_val_min1 = minute_counter_1;
            display_val_min2 = minute_counter_2;
        end
    end    

    decoder sec_block_1(
        .inp (display_val_sec1),
        .out (segment_1)
    );
    
    decoder sec_block_2(
        .inp (display_val_sec2),
        .out (segment_2)
    );

    decoder min_block_1(
        .inp (display_val_min1),
        .out (segment_3)
    );

    decoder min_block_2(
        .inp (display_val_min2),
        .out (segment_4)
    );

endmodule
