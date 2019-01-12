`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:21:13 05/01/2016 
// Design Name: 
// Module Name:    timer 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module stopwatch(
	input clk,
	input switch_stopwatch,
	input start_button,
	input pause_button,
	input reset_button,
	output reg [23:0] stopwatch_display = 24'b0
	);

	//the two minute digits
	reg [3:0] min_left;
	reg [3:0] min_right;
	//the two second digits
	reg [3:0] sec_left;
	reg [3:0] sec_right;
	//the two centisecond digits
	reg [3:0] cen_left;
	reg [3:0] cen_right;
	
	wire clean_start;
	wire clean_pause;
	wire clean_reset;
	
	debouncer debounce_start(start_button, clk, clean_start);
	debouncer debounce_pause(pause_button, clk, clean_pause);
	debouncer debounce_reset(reset_button, clk, clean_reset);

	
	//create a clock whose period is 100 millisecond
	centisecond_clock centisecond_clock1(clk, centisecond_clock);
	reg [1:0] stopwatch_state = 2'b00;
	
	always @(negedge clk)
	begin
		if (clean_reset & switch_stopwatch)	//clear state
			stopwatch_state <= 2'b00;
		else if (clean_start & switch_stopwatch)	//running state
			stopwatch_state <= 2'b01;
		else if (clean_pause & switch_stopwatch)	//paused state
			stopwatch_state <= 2'b10;
	end
	
	always @(posedge centisecond_clock)
	begin
		if (stopwatch_state == 2'b00)
			begin
			{min_left, min_right, sec_left, sec_right, cen_left, cen_right} <= 0;
			stopwatch_display <= 0;
			end

		else if (stopwatch_state == 2'b01)
			begin
			if (cen_right < 9)
				cen_right <= cen_right + 1;
			else if (cen_left < 9)
				begin cen_right <= 0; cen_left <= cen_left + 1; end
			else if (sec_right < 9)
				begin {cen_right, cen_left} <= 8'b0; sec_right <= sec_right + 1; end
			else if (sec_left < 5)
				begin {cen_right, cen_left} <= 8'b0; sec_right <= 0; sec_left <= sec_left + 1; end
			else if (min_right < 9)
				begin {cen_right, cen_left} <= 8'b0; sec_right <= 0; sec_left <= 0; min_right <= min_right + 1; end
			else if (min_left < 5)
				begin {cen_right, cen_left} <= 8'b0; sec_right <= 0; sec_left <= 0; min_right <= 0; min_left <= min_left + 1; end
			else
				begin {cen_right, cen_left} <= 8'b0; sec_right <= 0; sec_left <= 0; min_right <= 0; min_left <= 0; end
			end 
			
		else if (stopwatch_state == 2'b10)
			begin
			stopwatch_display <= {min_left, min_right, sec_left, sec_right, cen_left, cen_right};
			end
		stopwatch_display <= {min_left, min_right, sec_left, sec_right, cen_left, cen_right};		
	end
			
endmodule
