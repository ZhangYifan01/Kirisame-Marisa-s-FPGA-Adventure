/* Top level module of the FPGA that takes the onboard resources 
 * as input and outputs the lines drawn from the VGA port.
 *
 * Inputs:
 *   KEY 			- On board keys of the FPGA
 *   SW 			- On board switches of the FPGA
 *   CLOCK_50 		- On board 50 MHz clock of the FPGA
 *
 * Outputs:
 *   HEX 			- On board 7 segment displays of the FPGA
 *   LEDR 			- On board LEDs of the FPGA
 *   VGA_R 			- Red data of the VGA connection
 *   VGA_G 			- Green data of the VGA connection
 *   VGA_B 			- Blue data of the VGA connection
 *   VGA_BLANK_N 	- Blanking interval of the VGA connection
 *   VGA_CLK 		- VGA's clock signal
 *   VGA_HS 		- Horizontal Sync of the VGA connection
 *   VGA_SYNC_N 	- Enable signal for the sync of the VGA connection
 *   VGA_VS 		- Vertical Sync of the VGA connection
 *
 * Implements the lab 5, task 3 animation using the Animation and line_drawer2 modules.
 * Use SW[9] to force the screen to be cleared
 * Use KEY[0] to reset the system
 */
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	assign LEDR[8:0] = SW[8:0];
	
	logic [10:0] x, y;
	logic [7:0] xin, yin, titlex, titley;
	logic l ,r, u, d, GameClock;
	logic [9:0][7:0] ex, ey;
	
	VGA_framebuffer fb (
		.clk50			(CLOCK_50), 
		.reset			(1'b0), 
		.x, 
		.y,
		.pixel_color	(colour), 
		.pixel_write	(1'b1),
		.VGA_R, 
		.VGA_G, 
		.VGA_B, 
		.VGA_CLK, 
		.VGA_HS, 
		.VGA_VS,
		.VGA_BLANK_n	(VGA_BLANK_N), 
		.VGA_SYNC_n		(VGA_SYNC_N));
				
	logic reset, colour, clear;
	Animation #(.CLOCKDIV(21), .SQSIZE(64)) Ani(.x, .y, .colour, .forceClear(clear), .clk(CLOCK_50), .rst(reset),
					.xin(xin), .yin(yin), .GameClock(GameClock), .ex(ex), .ey(ey), .titlex(titlex), .titley(titley));
	Synchronizer SyncClear(.out(clear), .in(SW[9]), .clk(CLOCK_50), .rst(reset));
	assign reset = SW[8];
	
	Synchronizer Syncleft(.out(l), .in(~KEY[3]), .clk(CLOCK_50), .rst(reset));
	Synchronizer Syncright(.out(r), .in(~KEY[0]), .clk(CLOCK_50), .rst(reset));
	Synchronizer Syncup(.out(u), .in(~KEY[2]), .clk(CLOCK_50), .rst(reset));
	Synchronizer Syncdown(.out(d), .in(~KEY[1]), .clk(CLOCK_50), .rst(reset));
	location lo (.left(l), .right(r), .up(u), .down(d), .GameClock(GameClock),
					.xin(xin), .yin(yin), .reset(reset), .ex(ex), .ey(ey), .titlex(titlex), .titley(titley), .start(SW[0]), .hurt(LEDR[9]));
	

endmodule  // DE1_SoC
