module death(input [9:0] t1x, t1y, t2x, t2y,
				 input [9:0] b1x, b1y, b2x, b2y, b3x, b3y, b4x, b4y, b5x, b5y, b6x, b6y,
				 output redL, greenL);
int b1t1x, b1t1y, b2t1x, b2t1y, b3t1x, b3t1y, b4t1x, b4t1y, b5t1x, b5t1y, b6t1x, b6t1y;
int b1t2x, b1t2y, b2t2x, b2t2y, b3t2x, b3t2y, b4t2x, b4t2y, b5t2x, b5t2y, b6t2x, b6t2y;
pos_diff bu1t1x(.num1(t1x), .num2(b1x), .diff(b1t1x));
pos_diff bu1t1y(.num1(t1y), .num2(b1y), .diff(b1t1y));
pos_diff bu2t1x(.num1(t1x), .num2(b2x), .diff(b2t1x));
pos_diff bu2t1y(.num1(t1y), .num2(b2y), .diff(b2t1y));
pos_diff bu3t1x(.num1(t1x), .num2(b3x), .diff(b3t1x));
pos_diff bu3t1y(.num1(t1y), .num2(b3y), .diff(b3t1y));
pos_diff bu4t1x(.num1(t1x), .num2(b4x), .diff(b4t1x));
pos_diff bu4t1y(.num1(t1y), .num2(b4y), .diff(b4t1y));
pos_diff bu5t1x(.num1(t1x), .num2(b5x), .diff(b5t1x));
pos_diff bu5t1y(.num1(t1y), .num2(b5y), .diff(b5t1y));
pos_diff bu6t1x(.num1(t1x), .num2(b6x), .diff(b6t1x));
pos_diff bu6t1y(.num1(t1y), .num2(b6y), .diff(b6t1y));

pos_diff bu1t2x(.num1(t2x), .num2(b1x), .diff(b1t2x));
pos_diff bu1t2y(.num1(t2y), .num2(b1y), .diff(b1t2y));
pos_diff bu2t2x(.num1(t2x), .num2(b2x), .diff(b2t2x));
pos_diff bu2t2y(.num1(t2y), .num2(b2y), .diff(b2t2y));
pos_diff bu3t2x(.num1(t2x), .num2(b3x), .diff(b3t2x));
pos_diff bu3t2y(.num1(t2y), .num2(b3y), .diff(b3t2y));
pos_diff bu4t2x(.num1(t2x), .num2(b4x), .diff(b4t2x));
pos_diff bu4t2y(.num1(t2y), .num2(b4y), .diff(b4t2y));
pos_diff bu5t2x(.num1(t2x), .num2(b5x), .diff(b5t2x));
pos_diff bu5t2y(.num1(t2y), .num2(b5y), .diff(b5t2y));
pos_diff bu6t2x(.num1(t2x), .num2(b6x), .diff(b6t2x));
pos_diff bu6t2y(.num1(t2y), .num2(b6y), .diff(b6t2y));
int dis;
assign dis = 81;
always_comb
begin 
	//difference between bullet and tank is 
	redL = 0;
	greenL = 0;
	if (b1t1x*b1t1x+b1t1y*b1t1y <= dis)
		greenL = 1;
	else if (b2t1x*b2t1x+b2t1y*b2t1y <= dis)
		greenL = 1;
	else if (b3t1x*b3t1x+b3t1y*b3t1y <= dis)
		greenL = 1;
	else if (b4t1x*b4t1x+b4t1y*b4t1y <= dis)
		greenL = 1;
	else if (b5t1x*b5t1x+b5t1y*b5t1y <= dis)
		greenL = 1;
	else if (b6t1x*b6t1x+b6t1y*b6t1y <= dis)
		greenL = 1;
	else
		greenL = 0;
	
	if (b1t2x*b1t2x+b1t2y*b1t2y <= dis)
		redL = 1;
	else if (b2t2x*b2t2x+b2t2y*b2t2y <= dis)
		redL = 1;
	else if (b3t2x*b3t2x+b3t2y*b3t2y <= dis)
		redL = 1;
	else if (b4t2x*b4t2x+b4t2y*b4t2y <= dis)
		redL = 1;
	else if (b5t2x*b5t2x+b5t2y*b5t2y <= dis)
		redL = 1;
	else if (b6t2x*b6t2x+b6t2y*b6t2y <= dis)
		redL = 1;
	else
		redL = 0;
end
			
endmodule 