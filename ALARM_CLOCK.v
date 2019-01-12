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

/* The top module working as the integrator and effector (gathering, analyzing information
and making decisions. */

module ALARM_CLOCK(
	input clk, //the 50MHz built-in clock
/* Except that the switch_set_alarm has to be different from switch_set_time,
all the rest buttons can be shared with the time_setting module.
Also switch_set_time has a higher priority than switch_set_alarm*/
	input switch_set_time,		//kept on while setting the time. Switch R17
	input switch_set_alarm,		//kept on while setting the alarm. Switch N17
	input switch_stopwatch,		//turns on the stopwatch. L13
	input switch_timer,		   //turns on the timer. L14
	input switch_set_timer,    //allows user to set timer. K17
	input button_left,			//BTN3 (H13)
	input button_right,			//BTN2 (B18)
	input button_increase,		//BTN1 (D18)
	input button_decrease,		//BTN0 (E18)
	input switch_confirm,		//to confirm the setting. Switch G18
	input cancel_alarm,			//cancel the alarm. Switch H18
// These are the outputs heading to the display_screen module.
	output lcd_rs, lcd_rw, lcd_e, lcd_4, lcd_5, lcd_6, lcd_7, //LCD arrays for display

// This is the alarm indicator
	output speaker_out			//L15
	 );
	 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire [4:0] switch_state = {switch_set_time,switch_set_alarm,switch_stopwatch,switch_timer,switch_set_timer};
wire [23:0] display_pattern;
wire [5:0] blinking_pattern;
wire [23:0] time_display;
wire [23:0] intended_time;
wire [5:0] blinking_pattern_time;
wire [23:0] alarm_display;
wire [23:0] intended_alarm;
wire [5:0] blinking_pattern_alarm;
wire [23:0] clock_display;
wire [23:0] stopwatch_display;	
wire [23:0] timer_display;
wire [23:0] set_timer_display;
wire [23:0] intended_set_timer;
wire [5:0] blinking_pattern_set_timer;
wire clock_propagate;
wire timer_propagate;

time_setting time_setting(clk,switch_set_time,button_left,button_right,button_increase,button_decrease,switch_confirm,time_display,intended_time,blinking_pattern_time);
alarm_setting alarm_setting(clk,switch_set_alarm,button_left,button_right,button_increase,button_decrease,switch_confirm,cancel_alarm,alarm_display,intended_alarm,blinking_pattern_alarm);
timer_setting timer_setting(clk, switch_state[1:0], button_left, button_right, button_increase, button_decrease, switch_confirm, set_timer_display, intended_set_timer, blinking_pattern_set_timer);
display_screen display_screen(switch_state,display_pattern, clk, blinking_pattern, lcd_rs, lcd_rw, lcd_e, lcd_4, lcd_5, lcd_6, lcd_7);
stopwatch stopwatch(clk, switch_stopwatch, button_left, button_decrease, button_increase, stopwatch_display);
actual_clock actual_clock(clk, clock_propagate, intended_time,clock_display);
timer timer(clk, switch_state[1:0],timer_propagate, intended_set_timer, button_left, button_decrease, button_increase, timer_display);
alarm_checker alarm_checker(clk,display_pattern, intended_alarm, timer_display, speaker_out);

assign display_pattern = (switch_state[4] == 1'b1 ? time_display			// if we are setting time, we display the time_setting display pattern
								    :switch_state[3] == 1'b1 ? alarm_display		// if we are setting alarm, we display the alarm_setting display pattern
									 : switch_state[2] == 1'b1 ?  stopwatch_display	//if we are turning on the stopwatch, we display the stopwatch display pattern
									 : switch_state[1:0] == 2'b10 ? timer_display //if we are turning on the timer, we display the timer display pattern
									 : switch_state[1:0] == 2'b11 ? set_timer_display
   																: clock_display);		// if we are doing none above, we display the actual_clock display pattern
																		
assign blinking_pattern = (switch_state[4] == 1'b1 ? blinking_pattern_time		// if we are setting time, the blinking pattern is determined by time_setting module
								     :switch_state[3] == 1'b1 ? blinking_pattern_alarm	// if we are setting alarm, the blinking pattern is determined by alarm_setting module
									  :switch_state[1:0] == 2'b11 ? blinking_pattern_set_timer //if we are setting timer, the blinking pattern is determined by timer_set module
    																: 6'b000000);						// if we are doing neither above, no digit is blinking

assign clock_propagate = (switch_state[4] == 1'b1 & switch_confirm ? 1 : 0);		// if the user is confirming the time_setting, tell the actual_clock
assign timer_propagate = ((switch_state[1:0] == 2'b11) & switch_confirm ? 1 : 0);	// if the user is confirming the timer_setting, tell the timer
																		
endmodule
