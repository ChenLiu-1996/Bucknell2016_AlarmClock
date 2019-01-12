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

module one_second_clock (
    input clk,
    output reg one_sec_clock
	 );
	 reg [25:0] one_sec_counter = 0;
	 always @(posedge clk)
		begin
		if (one_sec_counter < 25000000)
			one_sec_counter <= one_sec_counter + 1;
		else
			begin
			one_sec_counter <=0;
			one_sec_clock <= ~one_sec_clock;
			end
		end
endmodule