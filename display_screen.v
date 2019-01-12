`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:27:17 02/17/2012 
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
module display_screen(
	 input [4:0] switch_state,
    input [23:0] display_pattern,	         //the numbers to be displayed
    input clk,                //the synchronizing clock working at 50MHz (see ucf file)
	 input [5:0] blinking_pattern, //select which digits will blink
    output lcd_rs, lcd_rw, lcd_e, lcd_4, lcd_5, lcd_6, lcd_7
										//by specifying the HIGH/LOW state of anodes
    );
	 
	wire currently_blinking_5;
	wire currently_blinking_4;
	wire currently_blinking_3;
	wire currently_blinking_2;
	wire currently_blinking_1;
	wire currently_blinking_0;
	reg blinking =0; //this is a counter that keeps the blink rate 
	
	one_second_clock one_second_clock2(clk, one_second_clock);
	always @(posedge one_second_clock)
		blinking<=~blinking;	//the digit that is supposed to blink will go on and off each second

	assign currently_blinking_5 =  (blinking & blinking_pattern[5]);
	assign currently_blinking_4 =  (blinking & blinking_pattern[4]);
	assign currently_blinking_3 =  (blinking & blinking_pattern[3]);
	assign currently_blinking_2 =  (blinking & blinking_pattern[2]);
	assign currently_blinking_1 =  (blinking & blinking_pattern[1]);
	assign currently_blinking_0 =  (blinking & blinking_pattern[0]);
	
	wire [79:0] display_status; //the current status (set time, set alarm, clock)
	// CAREFUL: the display status has to be 10 characters (including the spaces)!!
	assign display_status = (switch_state[4] == 1'b1 ? " SET CLOCK"				// if we are setting time, we display the words "SET CLOCK"
								    : switch_state[3] == 1'b1 ? " SET ALARM"			// if we are setting alarm, we display the words "SET ALARM"
									 : switch_state[2] == 1'b1 ?  "STOP WATCH"	//if we are turning on the stopwatch, we display the the words "STOPWATCH"
									 : switch_state[1:0] == 2'b10 ? "  TIMER   "    //if we are turning on the timer, we display the words "TIMER"
									 : switch_state[1:0] == 2'b11 ? " SET TIMER"
														         : "   CLOCK  ");		// if we are doing neither, we display the words "CLOCK"
	wire [7:0]colon;
	wire [7:0]colon_or_decimalPT;
	wire [7:0]char_0;
	wire [7:0]char_1;
	wire [7:0]char_2;
	wire [7:0]char_3;
	wire [7:0]char_4;
	wire [7:0]char_5;
	
	LCD_pattern_decoder decoder0(display_pattern[23:20],currently_blinking_5,char_0[7:0]);
	LCD_pattern_decoder decoder1(display_pattern[19:16],currently_blinking_4,char_1[7:0]);
	LCD_pattern_decoder decoder2(display_pattern[15:12],currently_blinking_3,char_2[7:0]);
	LCD_pattern_decoder decoder3(display_pattern[11:8],currently_blinking_2,char_3[7:0]);
	LCD_pattern_decoder decoder4(display_pattern[7:4],currently_blinking_1,char_4[7:0]);
	LCD_pattern_decoder decoder5(display_pattern[3:0],currently_blinking_0,char_5[7:0]);

	assign colon = ":";
	assign colon_or_decimalPT = (switch_state[2]== 1'b1 ? "." : ":");
	
	LCD_decoder LCD_decoder(clk, {{3{" "}},display_status, {7{" "}},char_0,char_1,colon,char_2,char_3,colon_or_decimalPT,char_4,char_5,{4{" "}}}, lcd_rs, lcd_rw, lcd_e, lcd_4, lcd_5, lcd_6, lcd_7);
		
endmodule

module LCD_pattern_decoder(
	input [3:0] display_pattern,
	input currently_blinking,
	output [7:0] LCD_pattern
	);
	
	assign LCD_pattern = ( currently_blinking == 1 ? " "
								: (currently_blinking == 0 & display_pattern == 4'b0000) ? "0"
								: (currently_blinking == 0 & display_pattern == 4'b0001) ? "1"
								: (currently_blinking == 0 & display_pattern == 4'b0010) ? "2"
								: (currently_blinking == 0 & display_pattern == 4'b0011) ? "3"
								: (currently_blinking == 0 & display_pattern == 4'b0100) ? "4"
								: (currently_blinking == 0 & display_pattern == 4'b0101) ? "5"
								: (currently_blinking == 0 & display_pattern == 4'b0110) ? "6"
								: (currently_blinking == 0 & display_pattern == 4'b0111) ? "7"
								: (currently_blinking == 0 & display_pattern == 4'b1000) ? "8"
								: (currently_blinking == 0 & display_pattern == 4'b1001) ? "9"
								: " ");
endmodule
