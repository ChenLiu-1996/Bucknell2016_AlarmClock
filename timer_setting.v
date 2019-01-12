`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:52:06 05/04/2016 
// Design Name: 
// Module Name:    countdown_set 
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
module timer_setting(
	input clk,
	input [1:0] switch_state,
	input button_left,			
	input button_right,			
	input button_increase,		
	input button_decrease,		
	input switch_confirm,				
	output reg [23:0] set_timer_display,//this is the pattern that is going to be displayed
										//remember you also want to display it even if the user
										//is in the process of setting time. You can still use this
										//variable name but it may not mean "intended" timer
	output reg [23:0] intended_set_timer,	
	output reg [5:0] blinking_pattern	//Which digit shall blink. 1 for blinking, 0 for stationary.
	);
	

wire clean_button_left;
wire clean_button_right;
wire clean_button_increase;
wire clean_button_decrease;
wire clean_switch_confirm;

debouncer debounce_left3(button_left,clk,clean_button_left);
debouncer debounce_right3(button_right,clk,clean_button_right);
debouncer debounce_increase3(button_increase,clk,clean_button_increase);
debouncer debounce_decrease3(button_decrease,clk,clean_button_decrease);
debouncer debounce_confirm3(switch_confirm,clk,clean_switch_confirm);

//the two hour digits
reg [3:0] hour_left;
reg [3:0] hour_right;
//the two minute digits
reg [3:0] min_left;
reg [3:0] min_right;
//the two second digits
reg [3:0] sec_left;
reg [3:0] sec_right;

initial
	blinking_pattern = 6'b100000;

always @ (posedge clk)
	begin
		if (switch_state[0] == 0)
			{hour_left,hour_right,min_left,min_right,sec_left,sec_right} <= intended_set_timer;
			else if (switch_state[1:0] == 2'b11)
			begin
				if (clean_switch_confirm == 1)
					intended_set_timer <= set_timer_display;
				else
					begin
					set_timer_display <= {hour_left,hour_right,min_left,min_right,sec_left,sec_right};
					if (clean_button_right == 1)
						case (blinking_pattern)
						6'b100000: blinking_pattern <= 6'b010000;
						6'b010000: blinking_pattern <= 6'b001000;
						6'b001000: blinking_pattern <= 6'b000100;
						6'b000100: blinking_pattern <= 6'b000010;
						6'b000010: blinking_pattern <= 6'b000001;
						6'b000001: blinking_pattern <= 6'b100000;
						endcase			
					else if (clean_button_left == 1)
						case (blinking_pattern)
						6'b100000: blinking_pattern <= 6'b000001;
						6'b010000: blinking_pattern <= 6'b100000;
						6'b001000: blinking_pattern <= 6'b010000;
						6'b000100: blinking_pattern <= 6'b001000;
						6'b000010: blinking_pattern <= 6'b000100;
						6'b000001: blinking_pattern <= 6'b000010;
						endcase
					else if (clean_button_increase == 1)
						case (blinking_pattern)
							6'b100000: begin if (hour_left < 9) hour_left <= hour_left + 1; else hour_right <= 0; end
							6'b010000: begin if (hour_right < 9) hour_right <= hour_right + 1; else hour_right <= 0; end
							6'b001000: begin if (min_left < 5) min_left <= min_left + 1; else min_left <= 0; end
							6'b000100: begin if (min_right < 9) min_right <= min_right + 1; else min_right <= 0; end
							6'b000010: begin if (sec_left < 5) sec_left <= sec_left + 1; else sec_left <= 0; end
							6'b000001: begin if (sec_right < 9) sec_right <= sec_right + 1; else sec_right <= 0; end
						endcase
					else if (clean_button_decrease == 1)
						case (blinking_pattern)
							6'b100000: begin if (hour_left > 0 ) hour_left <= hour_left - 1; else hour_left <= 9; end
							6'b010000: begin if (hour_right > 0 ) hour_right <= hour_right - 1; else hour_right <= 9; end
							6'b001000: begin if (min_left > 0 ) min_left <= min_left - 1; else min_left <= 5; end
							6'b000100: begin if (min_right > 0 ) min_right <= min_right - 1; else min_right <= 9; end
							6'b000010: begin if (sec_left > 0 ) sec_left <= sec_left - 1; else sec_left <= 5; end
							6'b000001: begin if (sec_right > 0 ) sec_right <= sec_right - 1; else sec_right <= 9; end
						endcase
					end
			end
	end
endmodule
