module bullet (input ywall, xwall, trigger, reset, frame_clk, fclk, timer_clk,
					input [6:0] angleshot, 
					input [9:0] xshot, yshot, x_start,
					output [9:0] x, y,
					output shot);
//logic will be external from tank

//local vars
logic [13:0] cur_x, cur_y, start_x, start_y;
logic xdir, ydir, tempshot, pos, flagx, flagy, flag;
logic [6:0] angle;
logic [8:0] sin, cos, sin1, cos1;
logic [8:0] motion_x, motion_y;
trig trig_0(.angle(angle), .sin(sin), .cos(cos));
trig trig_1(.angle(angleshot), .sin(sin1), .cos(cos1));
always_comb
begin
	//calculations to reduce time in always_ff
	start_x = (cos1[8] ? (~({6'h0,cos1[7:0]}*4'd14))+1'b1 : ({6'h0,cos1[7:0]}*4'd14));
	start_y = (sin1[8] ? ({6'h0,sin1[7:0]}*4'd14) : (~({6'h0,sin1[7:0]}*4'd14))+1'b1);
	motion_x <= (cos==0) ? 9'b0 : {cos[8]^xdir, 3'b100*cos[7:0]};
	motion_y <= (sin==0) ? 9'b0 : {sin[8]^ydir, 3'b100*sin[7:0]};
end
always_ff @ (posedge frame_clk or posedge reset)
begin
	if (reset)
	begin
		cur_x <= {x_start, 4'h0};
		xdir <= 0;
		ydir <= 0;
		tempshot <= 0;
		cur_y <= {10'd461, 4'h0};
		angle <= 0;
		flag <= 0;
		timer_ip <= 0;
	end else if(timer_done) begin
		cur_x <= {x_start, 4'h0};
		xdir <= 0;
		ydir <= 0;
		tempshot <= 0;
		cur_y <= {10'd461, 4'h0};
		angle <= 0;
		flag <= 0;
		timer_ip <= 0;
	end
	//being shot
	else
	begin
		if(trigger & (~tempshot))
		begin
		//if the bullet is shot
			angle <= angleshot;
			cur_x = ({xshot, 4'h0} + start_x);
			cur_y = ({yshot, 4'h0} + start_y);
			tempshot = 1'b1;
			timer_ip <= 1'b1;
		end
		else if (tempshot)
		//update the bullets position after being shot
		begin
			timer_ip <= 1'b1;
			if (flag) begin
			//stop glitching through the walls. 
				cur_x <= cur_x + 14'(signed'(motion_x[8] ? (~motion_x[7:0])+1 : motion_x[7:0]));
				cur_y <= cur_y + 14'(signed'(motion_y[8] ? motion_y[7:0] : (~motion_y[7:0])+1));
				flag = (ywall|xwall);
			end else if (ywall & xwall) begin
				ydir <= (~ydir);
				xdir <= (~xdir);
				flag = 1;
			end else if (ywall) begin
				ydir <= (~ydir);
				flag = 1;
				flagy = 1;
			end else if (xwall) begin
				xdir <= (~xdir);
				flag = 1;
				flagx = 1;
			end else begin
				flagx = 0;
				flagy = 0;
				cur_x <= cur_x + 14'(signed'(motion_x[8] ? (~motion_x[7:0])+1 : motion_x[7:0]));
				cur_y <= cur_y + 14'(signed'(motion_y[8] ? motion_y[7:0] : (~motion_y[7:0])+1));
			end
		end
	end
end

logic [2:0] counter;
logic timer_ip, timer_done;
always_ff @ (posedge timer_clk or posedge reset) begin
	if(reset) begin
		counter <= 0;
		timer_done <= 0;
	end else if(~timer_ip) begin
		counter <= 0;
		timer_done <= 0;
	end else begin
	
		if(counter == 3'b100)
			timer_done <= 1;
		else begin
			timer_done <= 0;
			counter <= counter + 1;
		end
			
	end
end

assign x = cur_x[13:4];
assign y = cur_y[13:4];
assign shot = tempshot;

endmodule 