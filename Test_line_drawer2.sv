// Automatically tests the line_drawer2 module with a veriety of line configurations, as well as a screen clear.
module Test_line_drawer2;
	logic [10:0] x, y;
    logic done, colour;
	logic [10:0] x0, y0, x1, y1;
    logic start, clear;
	logic clk, reset;

    line_drawer2 DUT(.x, .y, .done, .colour, .x0, .y0, .x1, .y1, .start, .clear, .clk, .reset);

    initial
    begin
        clk <= '0;
        forever #100 clk <= ~clk;
    end

    task Reset;
        x0 <= '0;
        x1 <= '0;
        y0 <= '0;
        y1 <= '0;
        start <= '0;
        clear <= '0;

        reset <= '1; @(posedge clk);
        reset <= '0; @(posedge clk);
    endtask

    int Cycles;
    task StartAndWait;
        start <= '1; @(posedge clk);
        Cycles = 0;
        while(!done && Cycles < 100000)
        begin
            Cycles++;
            @(posedge clk);
        end
        assert(Cycles != 100000) else $display("Timed out!");
        $display("Took %d cycles.", Cycles);
        start <= '0;
        repeat(3) @(posedge clk);
    endtask

    task DrawLine(logic [10:0] xStart, logic [10:0] yStart, logic [10:0] xEnd, logic [10:0] yEnd);
        clear <= '0;
        x0 <= xStart;
        x1 <= xEnd;
        y0 <= yStart;
        y1 <= yEnd;

        $display("Drawing line...");
        StartAndWait();
    endtask

    task DoClear;
        clear <= '1;
        x0 <= 10'd150; // These 4 should have no effect, so setting random values
        x1 <= '0;
        y0 <= '1;
        y1 <= '1;

        $display("Clearing screen...");
        StartAndWait();
    endtask

    initial
    begin
        Reset();
        DrawLine(50, 50, 50, 150); // Vertical
        DrawLine(50, 50, 150, 50); // Horizontal
        DrawLine(0, 0, 319, 239); // Extents, left-down
        DoClear();
        DrawLine(0, 100, 319, 90); // Left-up, shallow
        DrawLine(0, 100, 20, 0); // Left-up, steep
        DrawLine(100, 100, 0, 0); // Right-up, 45 degree
        DrawLine(200, 100, 0, 101); // Right-down, very shallow
        DrawLine(200, 100, 0, 210); // Right-down, normal
        DrawLine(200, 10, 199, 210); // Right-down, very steep
        $stop;
    end
endmodule