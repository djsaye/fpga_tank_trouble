module bullet_col (input logic Clk,
							input logic [9:0] x, y,
							input logic [3:0] wall,
							output logic xcol, ycol,
							output logic [7:0] addr,
							output logic pos);
always_comb begin	

	addr = (y>>6)*5 + (x>>7);
	pos = x[6];
	//check if the bullet is at a corner
	if((x[5:0])>=6'd55 & (y[5:0])>=6'd55 & wall[2] & wall[3])begin
		xcol = 1;
		ycol = 1;
	end else if((x[5:0])<=6'd8 & (y[5:0])<=6'd8 & wall[0]&wall[1])begin
		xcol = 1;
		ycol = 1;
	end else if((x[5:0])<=6'd8 & (y[5:0])>=6'd55 & wall[1]&wall[2])begin
		xcol = 1;
		ycol = 1;
	end else if((x[5:0])>=6'd55 & (y[5:0])<=6'd8 & wall[3]&wall[0])begin
		xcol = 1;
		ycol = 1;
	end else begin
	//if not check if its hitting a wall
		xcol = ((((x[5:0])>=6'd58) & wall[3]) | (((x[5:0])<=6'd5) & wall[1]));
		ycol = ((((y[5:0])>=6'd58) & wall[2]) | (((y[5:0])<=6'd5) & wall[0]));
	end
end

endmodule
