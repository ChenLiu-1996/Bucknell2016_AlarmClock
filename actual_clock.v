`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:51:43 04/07/2016 
// Design Name: 
// Module Name:    ALARM_CLOCK 
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
module actual_clock(
	input clk, //the 50MHz built-in clock
	input clock_propagate,
	input [23:0] intended_time, //the initial conditon given by the time_setting via ALARM CLOCK
	output reg [23:0] clock_display	//the patterns to be displayed on the screen.
												//ex: 0000_0000_0001_0100_0000_0100 will be represent 0 0 : 1 4 : 0 4
	 );

	//the two hour digits
	reg [3:0] hour_left;
	reg [3:0] hour_right;
	//the two minute digits
	reg [3:0] min_left;
	reg [3:0] min_right;
	//the two second digits
	reg [3:0] sec_left;
	reg [3:0] sec_right;
	
	//create a clock whose period is one second
	one_second_clock one_second_clock1(clk, one_second_clock);


/////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// Helping the clock to recognize the reset signal ////////////////////////	
	reg signal_state;
	reg [25:0] mark = 0;
	reg [25:0] one_sec_counter = 0;

	always @(posedge clk)
		begin
		if (one_sec_counter < 25000000)
			one_sec_counter <= one_sec_counter + 1;
		else
			begin
			one_sec_counter <=0;
			end
		end
	//once the value is propagated to the actual clock
	//(triggered by the confirmation button when the user is setting the time),
	//we want the signal_state to hold the propagated signal for a full second
	//such that the propagated signal will be recognized by the actual clock
	always @(negedge clk)
		begin
		if (clock_propagate)	//reset state
			begin
			signal_state <= 1'b1;
			mark <= one_sec_counter;
			end
		else if (~clock_propagate & mark == one_sec_counter)//running state
			begin
			signal_state <= 1'b0;
			mark <= 0;
			end
		end	
//////////////////////////// Helping the clock to recognize the reset signal ////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////

	always @(posedge one_second_clock)
	begin		
		if (signal_state)
		begin
			hour_left <= intended_time[23:20];
			hour_right <= intended_time[19:16];
			min_left <= intended_time[15:12];
			min_right <= intended_time[11:8];
			sec_left <= intended_time[7:4];
			sec_right <= intended_time[3:0];
		end
		else if (~signal_state)
		begin
			if (sec_right < 9)
				sec_right <= sec_right + 1;
			else if (sec_left < 5)
				begin sec_right <= 0; sec_left <= sec_left + 1; end
			else if (min_right < 9)
				begin sec_right <= 0; sec_left <= 0; min_right <= min_right + 1; end
			else if (min_left < 5)
				begin sec_right <= 0; sec_left <= 0; min_right <= 0; min_left <= min_left + 1; end			
			else if ((hour_left < 2 & hour_right < 9) | (hour_left == 2 & hour_right < 3))
				begin sec_right <= 0; sec_left <= 0; min_right <= 0; min_left <= 0; hour_right <= hour_right + 1; end
			else if (hour_left < 2 & hour_right == 9)
				begin sec_right <= 0; sec_left <= 0; min_right <= 0; min_left <= 0; hour_right <= 0; hour_left <= hour_left + 1; end
			else if (hour_left == 2 & hour_right == 3)
				begin sec_right <= 0; sec_left <= 0; min_right <= 0; min_left <= 0; hour_right <= 0; hour_left <= 0; end
		end
	clock_display <= {hour_left,hour_right,min_left,min_right,sec_left,sec_right};
	end
endmodule
