`timescale 1ns / 1ps

module LCD_decoder(
	clk,
	chars,
	lcd_rs, lcd_rw, lcd_e, lcd_4, lcd_5, lcd_6, lcd_7);

	// inputs and outputs
	input       	clk;
	input [255:0] 	chars;
	output      	lcd_rs, lcd_rw, lcd_e, lcd_4, lcd_5, lcd_6, lcd_7;

	wire [255:0] 	chars;
	reg	 	lcd_rs, lcd_rw, lcd_e, lcd_4, lcd_5, lcd_6, lcd_7;

	// internal variables
	reg [5:0] 	lcd_code;
	reg [1:0] 	write = 2'b10;	// write code has 10 for rs rw

	// delays
	reg [1:0]	before_delay = 3;	// time before on
	reg [3:0]	on_delay = 13;		// time on
	reg [23:0]	off_delay = 750_001;	// time off

	// states and counters
	reg [6:0]	Cs = 0;					//current state
	reg [19:0]	count = 0;				//counter to observe delays (on/off/before)
	reg [1:0]	delay_state = 0;	   //counter for delay handler, selects appropriate case

	// character data
	reg [255:0]	chars_hold = "                                "; // temporary storage for chars
	wire [3:0]	chars_data [63:0];	// array of characters, 4 bits per index

	// output data reformatting 
	// redirects characters data to an array
	generate
	genvar i;
		for (i = 64; i > 0; i = i-1)
			begin : for_name
				assign chars_data[64-i] = chars_hold[i*4-1:i*4-4];
			end
	endgenerate

	always @ (posedge clk) begin

		// store character data
		if (Cs == 10 && count == 0) begin
			chars_hold <= chars;
		end

		// timing handler
		// set time when enable is off
		if (Cs < 3) begin
			case (Cs)
				0: off_delay <= 750_001;	// 15ms delay
				1: off_delay <= 250_001;	// 5ms delay
				2: off_delay <= 5_001;		// 0.1ms delay
			endcase
		end else begin
			if (Cs > 12) begin
				off_delay	<= 2_001;	// 40us delay
			end else begin
				off_delay	<= 250_001;	// 5ms delay
			end
		end

		//delay handler
		// delays during each state
		if (Cs < 80) begin
		case (delay_state)
			0: begin
					// enable is off, lcd_code assigned to output bits
					lcd_e <= 0;
					{lcd_rs,lcd_rw,lcd_7,lcd_6,lcd_5,lcd_4} <= lcd_code;
					if (count == off_delay) begin
						count <= 0;
						delay_state <= delay_state + 1;
					end else begin
						count <= count + 1;
					end
				end
			1: begin
					// data set before enable is on, ensure outputs are stable
					lcd_e <= 0;
					if (count == before_delay) begin
						count <= 0;
						delay_state <= delay_state + 1;
					end else begin
						count <= count + 1;
					end
				end
			2: begin
					// enable on, must be high for on_delay (13 clock cycles) as per LCD convention
					lcd_e <= 1;
					if (count == on_delay) begin
						count <= 0;
						delay_state <= delay_state + 1;
					end else begin
						count <= count + 1;
					end
				end
			3: begin
					// enable off with data set, enable high-to-low toggle sends output data
					lcd_e <= 0;
					if (count == before_delay) begin
						count <= 0;
						delay_state <= 0;
						Cs <= Cs + 1;		// next case
					end else begin
						count <= count + 1;
					end
				end
		endcase
		end

		// set lcd_code using Cs (current state) register
		if (Cs < 12) begin
			// initialization handler
			// initialize LCD
			case (Cs)
				0: lcd_code <= 6'h03;        // power-on initialization
				1: lcd_code <= 6'h03;		  // ghost state (little documentation)
				2: lcd_code <= 6'h03;		  // ghost state (little documentation)
				3: lcd_code <= 6'h02;        // final ghost state (little documentation but all 3 necessary)
				4: lcd_code <= 6'h02;        // function set (first four bits)
				5: lcd_code <= 6'h08;		  // function set (second four bits)
				6: lcd_code <= 6'h00;        // entry mode set (first four bits)
				7: lcd_code <= 6'h06;		  // entry mode set (second four bits)
				8: lcd_code <= 6'h00;        // display on/off control (first four bits)
				9: lcd_code <= 6'h0C;		  // display on/off control (second four bits)
				10:lcd_code <= 6'h00;        // display clear (first four bits)
				11:lcd_code <= 6'h01;		  // display clear (second four bits)
				default: lcd_code <= 6'h10;
			endcase
		end else begin

			// data handler 
			// set character data to lcd_code
			if (Cs == 44) begin			// change address at end of first line
				lcd_code <= {2'b00, 4'b1100};	// 1100 0000 address change
			end else if (Cs == 45) begin
				lcd_code <= {2'b00, 4'b0000};
			end else begin
				if (Cs < 44) begin
					lcd_code <= {write, chars_data[Cs-12]};
				end else begin
					lcd_code <= {write, chars_data[Cs-14]};
				end
			end

		end

		// Cs reset handler, restarts refresh cycle, observe off_delay
		if (Cs == 78) begin
			lcd_e <= 0;
			if (count == off_delay) begin
				Cs 			<= 8;
				count 		<= 0;
			end else begin
				count <= count + 1;
			end
		end

	end

endmodule