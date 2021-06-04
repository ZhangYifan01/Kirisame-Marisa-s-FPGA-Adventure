/* Given two points on the screen this module draws a line between
 * those two points by coloring necessary pixels
 *
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *   reset  - resets the module and starts over the drawing process
 *   start  - triggers the start of drawing/clearing if the system is ready
 *   clear  - determines whether the operation will be a line drawing (false) or a screen clear (true)
 *	 x0 	- x coordinate of the first end point
 *   y0 	- y coordinate of the first end point
 *   x1 	- x coordinate of the second end point
 *   y1 	- y coordinate of the second end point
 *
 * Outputs:
 *   x 		- x coordinate of the pixel to color
 *   y 		- y coordinate of the pixel to color
 *   done	- flag that line has finished drawing
 *   colour - whether to paint this pixel (on) or clear it (off)
 */
module line_drawer2
(
	output logic [10:0] x, y,
    output logic done, colour,
	input logic [10:0] x0, y0, x1, y1,
    input logic start, clear,
	input logic clk, reset
);
    logic initRegs, doClear, doLoop;
    logic loopFinished;

    LineDrawerCTRL CTRL(.done, .colour, .initRegs, .doClear, .doLoop, .start, .clear, .loopFinished, .clk, .reset);
    LineDrawerDPTH DPTH(.x, .y, .loopFinished, .x0, .y0, .x1, .y1, .initRegs, .doClear, .doLoop, .clk, .reset);
endmodule

// Control module for the line drawer
module LineDrawerCTRL
(
    output logic done, colour,
    output logic initRegs, doClear, doLoop,
    input logic start, clear,
    input logic loopFinished, // whether the line is done drawing
	input logic clk, reset
);
    typedef enum { READY, INITLINE, LOOPLINE, INITCLEAR, LOOPCLEAR, DONE, XXX } LineState;
    LineState Present, Next;

    always_ff @(posedge clk) // State register
        if(reset) Present <= READY;
        else Present <= Next;
    
    always_comb // Next state
    begin
        Next = XXX;
        case(Present)
            READY:
                if(start & clear) Next = INITCLEAR;
                else if(start & ~clear) Next = INITLINE;
                else Next = READY; // @LB
            INITLINE: Next = LOOPLINE;
            LOOPLINE:
                if(loopFinished) Next = DONE;
                else Next = LOOPLINE; // @LB
            INITCLEAR: Next = LOOPCLEAR;
            LOOPCLEAR:
                if(loopFinished) Next = DONE;
                else Next = LOOPCLEAR; // @LB
            DONE:
                if(start) Next = DONE; // @LB
                else Next = READY;
            default: Next = XXX;
        endcase
    end

    always_comb // Outputs
    begin
        done = Present == DONE;
        initRegs = Present == INITCLEAR || Present == INITLINE;
        doClear = Present == INITCLEAR || Present == LOOPCLEAR;
        doLoop = Present == LOOPCLEAR || Present == LOOPLINE;
        colour = ~doClear;
    end
endmodule

// Datapath module for the line drawer
module LineDrawerDPTH
(
    output logic [10:0] x, y,
    output logic loopFinished,
	input logic [10:0] x0, y0, x1, y1,
    input logic initRegs, doClear, doLoop,
	input logic clk, reset
);
    logic signed [11:0] DistX, DistY; // The distances in each direction (y negative)
    logic signed [12:0] Error;
    logic signed [13:0] Error2; // Error * 2
    logic StepXPsv, StepYPsv; // Whether we will step each coordinate in the positive direction

    localparam WIDTH = 320;
    localparam HEIGHT = 240;

    always_ff @(posedge clk)
    begin
        if(initRegs)
        begin
            StepXPsv <= (x0 < x1);
            StepYPsv <= (y0 < y1);
            x <= doClear ? '0 : x0;
            y <= doClear ? '0 : y0;
            Error <= DistX + DistY;
        end

        if(doLoop && ~doClear)
        begin
            if(Error2 >= DistY)
            begin
                Error <= Error + DistY;
                x <= (StepXPsv ? x + 1'd1 : x - 1'd1);
            end
            if(Error2 <= DistX)
            begin
                Error <= Error + DistX;
                y <= (StepYPsv ? y + 1'd1 : y - 1'd1);
            end
            // Special case: Make sure we calculate error correctly if both above statements are true
            if(Error2 >= DistY && Error2 <= DistX) Error <= Error + DistY + DistX;
        end

        if(doLoop && doClear)
        begin
            if(x == WIDTH - 1)
            begin
                x <= '0;
                y <= y + 1'd1;
            end
            else x <= x + 1'd1;
        end
    end

    always_comb
    begin
        DistX = (x1 > x0) ? (x1 - x0) : (x0 - x1);
        DistY = (y1 > y0) ? (y0 - y1) : (y1 - y0); // Y is negative
        Error2 = Error * 2'd2;

        if(doClear) loopFinished = (x == WIDTH - 1 && y == HEIGHT - 1);
        else loopFinished = (x == x1 && y == y1);
    end
endmodule