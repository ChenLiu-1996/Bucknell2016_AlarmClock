`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:07:03 05/04/2016 
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
module timer(
	input clk,
	input [1:0] switch_state,
	input timer_propagate,
	input [23:0] intended_set_timer,
	input button_left,		//start
	input button_decrease,	//pause
	input button_increase,	//reset
	output reg [23:0] timer_display
	);

wire clean_button_left;
wire clean_button_increase;
wire clean_button_decrease;

debouncer debounce_left4(button_left,clk,clean_button_left);
debouncer debounce_increase4(button_increase,clk,clean_button_increase);
debouncer debounce_decrease4(button_decrease,clk,clean_button_decrease);

//the two hour digits
reg [3:0] hour_left;
reg [3:0] hour_right;
//the two minute digits
reg [3:0] min_left;
reg [3:0] min_right;
//the two second digits
reg [3:0] sec_left;
reg [3:0] sec_right;
//the two centisecond digits -- THESE ARE NOT DISPLAYED. JUST TO INCREASE RECOGNITION SPEED
reg [3:0] cen_left;
reg [3:0] cen_right;
//create a clock whose period is 100 millisecond
centisecond_clock centisecond_clock2(clk, centisecond_clock);

/////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// Helping the clock to recognize the reset signal ////////////////////////	
reg signal_state;
reg [25:0] mark = 0;
reg [25:0] one_sec_counter = 0;
reg [1:0] timer_state = 2'b00;

	always @(posedge clk)
		begin
		if (one_sec_counter < 25000000)
			one_sec_counter <= one_sec_counter + 1;
		else
			begin
			one_sec_counter <=0;
			end
		end
	//once the value is propagated to the timer
	//(triggered by the confirmation button when the user is setting the timer),
	//we want the signal_state to hold the propagated signal for a full centisecond
	//such that the propagated signal will be recognized by the timer
	always @(negedge clk)
		begin
			begin
			if (timer_propagate)	// if the signal is propagated
				begin
				signal_state <= 1'b1;
				mark <= one_sec_counter;
				end
			else if (~timer_propagate & mark == one_sec_counter)//if the signal is held for long enough
				begin
				signal_state <= 1'b0;
				mark <= 0;
				end
			end
			begin
			if (clean_button_increase & (switch_state[1:0] == 2'b10))	//clear state
				timer_state <= 2'b10;
			else if (clean_button_left & (switch_state[1:0] == 2'b10))	//running state
				timer_state <= 2'b01;
			else if (clean_button_decrease & (switch_state[1:0] == 2'b10))	//paused state
				timer_state <= 2'b00;
			end	
		end

//////////////////////////// Helping the clock to recognize the reset signal ////////////////////////	
/////////////////////////////////////////////////////////////////////////////////////////////////////

always @ (posedge centisecond_clock)
	if (signal_state)
		begin
		{cen_left,cen_right} <= 8'b0000_0000;
		{hour_left,hour_right,min_left,min_right,sec_left,sec_right} <= intended_set_timer;
		timer_display <= {hour_left,hour_right,min_left,min_right,sec_left,sec_right};
		end
	else if (~signal_state)
		begin
			if (timer_state == 2'b00)
				begin
				end
			else if (timer_state == 2'b10)
				begin
				{hour_left,hour_right,min_left,min_right,sec_left,sec_right,cen_left,cen_right} <= 32'b1111_1111_1111_1111_1111_1111_1111_1111;
				end
			else if (timer_state == 2'b01)
				begin
					if (cen_right > 0)
						cen_right <= cen_right - 1;
					else if (cen_left > 0)
						begin cen_right <= 9; cen_left <= cen_left - 1; end
					else if (sec_right > 0)
						begin cen_right <= 9; cen_left <= 9; sec_right <= sec_right - 1; end
					else if (sec_left > 0)
						begin cen_right <= 9; cen_left <= 9; sec_right <= 9; sec_left <= sec_left - 1; end
					else if (min_right > 0)
						begin cen_right <= 9; cen_left <= 9; sec_right <= 9; sec_left <= 5; min_right <= min_right - 1; end
					else if (min_left > 0)
						begin cen_right <= 9; cen_left <= 9; sec_right <= 9; sec_left <= 5; min_right <= 9; min_left <= min_left - 1; end
					else if (hour_right > 0)
						begin cen_right <= 9; cen_left <= 9; sec_right <= 9; sec_left <= 5; min_right <= 9; min_left <= 5; hour_right <= hour_right - 1; end				
					else if (hour_left > 0 & hour_left < 10)
						begin cen_right <= 9; cen_left <= 9; sec_right <= 9; sec_left <= 5; min_right <= 9; min_left <= 5; hour_right <= 9; hour_left <= hour_left - 1; end
					else if (hour_left > 9)
						begin end
				end
			timer_display <= {hour_left, hour_right, min_left, min_right, sec_left, sec_right};
		end
endmodule
