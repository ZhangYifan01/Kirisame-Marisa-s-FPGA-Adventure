module location (left, right, up, down, xin, yin, reset, GameClock, ex, ey, titlex, titley, start, hurt);
	input logic left, right, up, down, reset, GameClock, start;
	output logic [7:0] xin, yin;
	logic [7:0] x, y;
	
	output logic [9:0][7:0] ex, ey;
	output logic [7:0] titlex, titley;
	output logic hurt;
	
	logic [12:0] count;
	initial begin
		x = 100;
		y = 190;
		hurt = 1'b0;
	end
	
	always_ff @(posedge GameClock) begin
		if (left && x != 10) x = x - 2;
		if (right && x != 190) x = x + 2;
		if (up && y != 40) y = y - 2;
		if (down && y != 230) y = y + 2;
	end
	
	always_ff @(posedge GameClock) begin
		if (start) begin
			count++;
			if(titley < 242) titley++;
			if (count > 260 && count < 500) begin
				ex[1] = 50;
				ey[1] = count - 250;
				ex[2] = 90;
				ey[2] = count - 250;
				ex[3] = 130;
				ey[3] = count - 250;
			end
			if (count > 360 && count < 600) begin
				ex[4] = 70;
				ey[4] = count - 350;
				ex[5] = 110;
				ey[5] = count - 350;
				ex[6] = 150;
				ey[6] = count - 350;
			end
			if (count > 460 && count < 700) begin
				ex[7] = 90;
				ey[7] = count - 450;
				ex[8] = 130;
				ey[8] = count - 450;
			end

			if (count > 720 && count < 1200) begin  //rom
				ex[9] = 70;
				ey[9] = 10;
			end
			
			if (count > 720 && count < 1200) begin
			
					ex[2] = ex[9] + 30;
					ey[2] = ey[9] + 1 + count % 240;

					ex[3] = ex[9] + 31 + (count%240)/3;
					ey[3] = ey[9] + 2 + count % 240;

					ex[4] = ex[9] + 29 - (count % 240)/3;
					ey[4] = ey[9] + 3 + count % 240;
			end
			
			if (count > 1200 && count < 1241) begin
				ey[9] = 10 + 6 * (count - 1200);
			end
			
			if (count > 1248 && count < 1250) begin
				ex[5] = ex[0] + 10;
				ey[5] = 255;
				ex[6] = ex[0] + 60;
				ey[6] = 255;
			end
			
			if (count > 1250 && count < 1500) begin //fpga
				ex[0] = 130 - (count-1250) / 3;
				ey[0] = 1490 - count;
			end
			
			if (count > 1500 && count < 1800) begin
				ex[0] = 50;
				ey[0] = 5;
			end
			
			if (count > 1800 && count < 1900) begin
				ex[0] = 50 + (count - 1800)/2;
				ey[0] = 5 + (count - 1800) / 4;
			end
			
			if (count > 1900 && count < 2000) begin
				ex[0] = 101 - (count - 1900);
				ey[0] = 5 + (count - 1800) / 4;
			end
			
			if (count > 2000 && count < 2100) begin
				ex[0] = 1 + (count - 2000);
				ey[0] = 5 + (count - 1800) / 4;
			end
			
			if (count > 2100 && count < 2200) begin
				ex[0] = 100 - (count - 2100) / 2;
				ey[0] = 5 + (count - 1800) / 4;
			end
			
			if (count > 2200 && count < 2275) begin
				ex[0] = 50;
				ey[0] = 105 + 2*(count - 2200);
			end
			
			if (count > 1500 && count < 2200) begin
				ex[5] = ex[0] + 10;
				ex[6] = ex[0] + 60;
				if (ey[5] < 250) ey[5] = ey[5] + 2;
				else ey[5] = ey[0] + 71;
				if (ey[6] < 250) ey[6] = ey[6] + 2;
				else ey[6] = ey[0] + 71;
			end
			
			if (count > 2203 && count < 2205) begin 
				ey[6] = 255;
				ey[5] = 255;
			end
			
			if (count > 2400) count = 250;
			
		end else begin
			ex[1] = 250;
			ey[1] = 255;
			ex[2] = 251;
			ey[2] = 255;
			ex[3] = 252;
			ey[3] = 255;
			ex[4] = 253;
			ey[4] = 255;
			ex[5] = 254;
			ey[5] = 255;
			ex[6] = 255;
			ey[6] = 255;
			ex[7] = 256;
			ey[7] = 255;
			ex[8] = 257;
			ey[8] = 255;
		
			ex[0] = 150;
			ey[0] = 249;
			ex[9] = 200;
			ey[9] = 250;
			titlex = 20;
			titley = 40;
			count = 0;
		end
	end
	
	
	always_ff @(posedge GameClock) begin  //damage
		if ((((xin > ex[1] - 5 ) && (xin < ex[1] + 5)) && ((yin < ey[1] + 5 ) && (yin > ey[1] - 5))) 
		 || (((xin > ex[2] - 5 ) && (xin < ex[2] + 5)) && ((yin < ey[2] + 5 ) && (yin > ey[2] - 5)))
		 || (((xin > ex[3] - 5 ) && (xin < ex[3] + 5)) && ((yin < ey[3] + 5 ) && (yin > ey[3] - 5)))
		 || (((xin > ex[4] - 5 ) && (xin < ex[4] + 5)) && ((yin < ey[4] + 5 ) && (yin > ey[4] - 5)))
		 || (((xin > ex[5] - 5 ) && (xin < ex[5] + 5)) && ((yin < ey[5] + 5 ) && (yin > ey[5] - 5)))
		 || (((xin > ex[6] - 5 ) && (xin < ex[6] + 5)) && ((yin < ey[6] + 5 ) && (yin > ey[6] - 5)))
		 || (((xin > ex[7] - 5 ) && (xin < ex[7] + 5)) && ((yin < ey[7] + 5 ) && (yin > ey[7] - 5)))
		 || (((xin > ex[8] - 5 ) && (xin < ex[8] + 5)) && ((yin < ey[8] + 5 ) && (yin > ey[8] - 5)))
		 || (((xin - ex[9] < 80 ) && (xin - ex[9] > 0)) && ((yin - ey[9] > 0 ) && (yin - ey[9] < 40 )))
		 || (((xin - ex[0] < 70 ) && (xin - ex[0] > 0)) && ((yin - ey[0] > 0 ) && (yin - ey[0] < 70 )))
		) hurt = 1'b1;
      else hurt = 1'b0;
	end
	
	always_comb begin
		xin = x;
		yin = y;
	end
endmodule
