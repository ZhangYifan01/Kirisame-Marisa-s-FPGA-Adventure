/* Given two points on the screen this module draws a line between
 * those two points by coloring necessary pixels
 *
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *   reset  - resets the module and starts over the drawing process
 *	 x0 	- x coordinate of the first end point
 *   y0 	- y coordinate of the first end point
 *   x1 	- x coordinate of the second end point
 *   y1 	- y coordinate of the second end point
 *
 * Outputs:
 *   x 		- x coordinate of the pixel to color
 *   y 		- y coordinate of the pixel to color
 *   done	- flag that line has finished drawing
 */
module line_drawer
(
	output logic [10:0] x, y,
	output logic done,
	input logic [10:0] x0, y0, x1, y1,
	input logic clk, reset
);
	logic signed [11:0] error, deltax, deltay, error2, errordx, errordy;
	logic is_steep; // The line's y travel is greater than x travel.
	logic [10:0] tempx, tempy;

	always_comb
	begin
		tempy = (y1 > y0) ? (y1 - y0) : (y0 - y1); // Absolute distance between y coords
		tempx = (x1 > x0) ? (x1 - x0) : (x0 - x1); // Absolute distance between x coords
		errordx = error + deltax;
		errordy = error + deltay;
	end

	always_ff @(posedge clk)
	begin
		if (reset) //initialize
		begin
			x <= x0;
			y <= y0;
			is_steep <= tempy > tempx;
			deltax <= tempx;
			error <= -(tempx / 11'd2);
			deltay <= tempy;
			//error2 <= -(tempy / 2);
		end
		else
		begin 
			if (is_steep) // if steep
			begin 
				if(y > y1)
				begin
					y <= y - 1'd1;
					error <= errordx;
					if (errordx >= 0)
					begin
						x <= (x0 < x1) ? (x + 1'd1) : (x - 1'd1);
						error <= errordx - deltay;
					end
				end
				if(y < y1)
				begin
					y <= y + 1'd1;
					error <= errordx;
					if (errordx >= 0)
					begin
						x <= (x0 < x1) ? (x + 1'd1) : (x - 1'd1);
						error <= errordx - deltay;
					end
				end
			end
			else
			begin // if flat
				if(x < x1)
				begin
					x <= x + 1'd1;
					error <= errordy;
					if (errordy >= 0)
					begin
						y <= (y0 < y1) ? (y + 1'd1) : (y - 1'd1);
						error <= errordy - deltax;
					end
				end
				if(x > x1)
				begin
					x <= x - 1'd1;
					error <= errordy;
					if (errordy >= 0)
					begin
						y <= (y0 < y1) ? (y + 1'd1) : (y - 1'd1);
						error <= errordy - deltax;
					end
				end
			end
		end
	end  // always_ff
endmodule  // line_drawer