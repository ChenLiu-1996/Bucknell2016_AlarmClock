`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:51:17 04/07/2016 
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
/*creates a clock whose period is one second*/

module centisecond_clock (
    input clk,
    output reg centisecond_clock
	 );
	 reg [17:0] centisecond_counter = 0;
	 always @(posedge clk)
		begin
		if (centisecond_counter < 250000)
			centisecond_counter <= centisecond_counter + 1;
		else
			begin
			centisecond_counter <=0;
			centisecond_clock <= ~centisecond_clock;
			end
		end
endmodule