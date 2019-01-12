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

/* This module is supposed to count the time after the alarm is set*/

module alarm_checker(
	input clk,
	input [23:0] current_time,	//precision up to 10 seconds
	input [23:0] intended_alarm,
	input [23:0] timer_display,
	output speaker_out
	);
wire speaker_alarm;
wire speaker_timer;

assign speaker_alarm = ((intended_alarm != 0) & (current_time >= intended_alarm)) ? 1 : 0;
assign speaker_timer = (timer_display == 24'b0) ? 1 : 0;

reg [15:0] counter;

always @(posedge clk) 
	begin
		if (counter == 65535) counter <= 0;
		else counter <= counter + 1;
	end

assign speaker_out = (speaker_alarm ? counter[13]
							: speaker_timer ? counter[15]
							: 0) ;

endmodule
