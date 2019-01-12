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
module debouncer(
	input raw,
	input clk,
	output reg clean
	);
	
	parameter N = 22;
	reg [N:0] count;
	
	always @(posedge clk)
	begin
		count <= (raw == 1 & count[N]!=1) ? (count + 1) : 0;
		clean <= (count[N]==1) ? 1:0;
	end
endmodule
