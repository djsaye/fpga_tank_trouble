module tank_two (input Reset, frame_clk,
						input [7:0] port_0, port_1, port_2, port_3, port_4, port_5,
						input front_col, back_col,
						output [9:0] tank_x, tank_y, 
						output [6:0] tank_angle);
						

		logic [13:0] x, y;
		logic [6:0] angle;
		logic [8:0] motion_x, motion_y;
		logic [1:0] motion;
		logic [6:0] rotation;
		logic [8:0] sin, cos;
		trig trig_0(.angle(angle), .sin(sin), .cos(cos));

		logic [5:0] up, down, right, left; //represents the values of the 
		
		always_comb 
		begin
		
			case (port_5) 
				8'h52 : begin
					up[5] = 1;
					down[5] = 0;
					right[5] = 0;
					left[5] = 0;
					end
				8'h50 : begin
					up[5] = 0;
					down[5] = 0;
					right[5] = 0;
					left[5] = 1;
					end
				8'h51 : begin
					up[5] = 0;
					down[5] = 1;
					right[5] = 0;
					left[5] = 0;
					end
				8'h4f : begin
					up[5] = 0;
					down[5] = 0;
					right[5] = 1;
					left[5] = 0;
					end
				default : begin
					up[5] = 0;
					down[5] = 0;
					right[5] = 0;
					left[5] = 0;
				end
			endcase
			
			case (port_4)
				8'h52 : begin
					up[4] = 1;
					down[4] = 0;
					right[4] = 0;
					left[4] = 0;
					end
				8'h50 : begin
					up[4] = 0;
					down[4] = 0;
					right[4] = 0;
					left[4] = 1;
					end
				8'h51 : begin
					up[4] = 0;
					down[4] = 1;
					right[4] = 0;
					left[4] = 0;
					end
				8'h4f : begin
					up[4] = 0;
					down[4] = 0;
					right[4] = 1;
					left[4] = 0;
					end
				default : begin
					up[4] = 0;
					down[4] = 0;
					right[4] = 0;
					left[4] = 0;
				end
			endcase
			
			case (port_4)
				8'h52 : begin
					up[4] = 1;
					down[4] = 0;
					right[4] = 0;
					left[4] = 0;
					end
				8'h50 : begin
					up[4] = 0;
					down[4] = 0;
					right[4] = 0;
					left[4] = 1;
					end
				8'h51 : begin
					up[4] = 0;
					down[4] = 1;
					right[4] = 0;
					left[4] = 0;
					end
				8'h4f : begin
					up[4] = 0;
					down[4] = 0;
					right[4] = 1;
					left[4] = 0;
					end
				default : begin
					up[4] = 0;
					down[4] = 0;
					right[4] = 0;
					left[4] = 0;
				end
			endcase
					
			case (port_3)
				8'h52 : begin
					up[3] = 1;
					down[3] = 0;
					right[3] = 0;
					left[3] = 0;
					end
				8'h50 : begin
					up[3] = 0;
					down[3] = 0;
					right[3] = 0;
					left[3] = 1;
					end
				8'h51 : begin
					up[3] = 0;
					down[3] = 1;
					right[3] = 0;
					left[3] = 0;
					end
				8'h4f : begin
					up[3] = 0;
					down[3] = 0;
					right[3] = 1;
					left[3] = 0;
					end
				default : begin
					up[3] = 0;
					down[3] = 0;
					right[3] = 0;
					left[3] = 0;
				end
			endcase
			
			case (port_2)
				8'h52 : begin
					up[2] = 1;
					down[2] = 0;
					right[2] = 0;
					left[2] = 0;
					end
				8'h50 : begin
					up[2] = 0;
					down[2] = 0;
					right[2] = 0;
					left[2] = 1;
					end
				8'h51 : begin
					up[2] = 0;
					down[2] = 1;
					right[2] = 0;
					left[2] = 0;
					end
				8'h4f : begin
					up[2] = 0;
					down[2] = 0;
					right[2] = 1;
					left[2] = 0;
					end
				default : begin
					up[2] = 0;
					down[2] = 0;
					right[2] = 0;
					left[2] = 0;
				end
			endcase
			
			case (port_1)
				8'h52 : begin
					up[1] = 1;
					down[1] = 0;
					right[1] = 0;
					left[1] = 0;
					end
				8'h50 : begin
					up[1] = 0;
					down[1] = 0;
					right[1] = 0;
					left[1] = 1;
					end
				8'h51 : begin
					up[1] = 0;
					down[1] = 1;
					right[1] = 0;
					left[1] = 0;
					end
				8'h4f : begin
					up[1] = 0;
					down[1] = 0;
					right[1] = 1;
					left[1] = 0;
					end
				default : begin
					up[1] = 0;
					down[1] = 0;
					right[1] = 0;
					left[1] = 0;
				end
			endcase
			
			
			case (port_0)
				8'h52 : begin
					up[0] = 1;
					down[0] = 0;
					right[0] = 0;
					left[0] = 0;
					end
				8'h50 : begin
					up[0] = 0;
					down[0] = 0;
					right[0] = 0;
					left[0] = 1;
					end
				8'h51 : begin
					up[0] = 0;
					down[0] = 1;
					right[0] = 0;
					left[0] = 0;
					end
				8'h4f : begin
					up[0] = 0;
					down[0] = 0;
					right[0] = 1;
					left[0] = 0;
					end
				default : begin
					up[0] = 0;
					down[0] = 0;
					right[0] = 0;
					left[0] = 0;
				end
			endcase
			
		end
		
		
		always_ff @ (posedge Reset or posedge frame_clk ) begin
		
			if(Reset) begin
				x <= {10'd608, 4'h0};
				y <= {10'd416, 4'h0};
				angle <= 7'd45;
			end else begin
					
				if(rotation == 7'b1111111 && angle == 0)
					angle <= 7'h59;
				else if(rotation == 1 && angle == 7'h59)
					angle <= 0;
				else 
					angle <= angle + rotation;
					
				x <= x + 14'(signed'(motion_x[8] ? (~motion_x[7:0])+1 : motion_x[7:0]));
				y <= y + 14'(signed'(motion_y[8] ? motion_y[7:0] : (~motion_y[7:0])+1));
				
			end
		end	
		
		
always_comb
begin
	if (~(up==0) && down==0)
		motion = (front_col ? 0 : 1);
	else if (up==0 && ~(down==0))
		motion = (back_col ? 0 : 2'b11);
	else
		motion = 0;
				
	if (back_col | front_col)
		rotation = 0;
	else if (right==0 && ~(left==0))
		rotation = 1;
	else if (~(right==0) && left==0)
		rotation = -1;
	else
		rotation = 0;
	if (motion != 0) begin
		motion_x = (cos==0) ? 9'b0 : {cos[8]^motion[1], 2'b10*cos[7:0]};
		motion_y = (sin==0) ? 9'b0 : {sin[8]^motion[1], 2'b10*sin[7:0]};
	end else begin
		motion_y = 0;
		motion_x = 0;
	end
	tank_x = x[13:4];
	tank_y = y[13:4];
	tank_angle = angle;

	tank_x = x[13:4];
	tank_y = y[13:4];
	tank_angle = angle;
	
end
		
endmodule			
				
					