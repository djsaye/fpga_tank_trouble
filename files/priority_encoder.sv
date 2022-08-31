module priority_encoder(input logic [3:0] color_red, color_green, color_blue,
								input logic [3:0] maze_red, maze_green, maze_blue,
								input logic [1:0] screen,
								input logic clk,
								input logic [9:0] drawx, drawy,
								output logic [3:0] red, green, blue);

logic gout, rout;
logic [1:0] startout;
logic [18:0] address;
assign address = {9'h0,drawx}+{2'h0,drawy,7'h0}+{2'h0,drawy,7'h0}+{2'h0,drawy,7'h0}+{2'h0,drawy,7'h0}+{2'h0,drawy,7'h0};
redwin r (.address(address),.clock(clk), .q(rout));
greenwin g (.address(address),.clock(clk), .q(gout));
start s (.address(address),.clock(clk), .q(startout));
	always_comb
	begin
		case(screen)
			2'b00:
				case(startout)
					2'b00: {red,green,blue} = {4'h0, 4'h0, 4'h0};
					2'b01: {red,green,blue} = {4'h4, 4'h4, 4'h4};
					2'b10: {red,green,blue} = {4'hD, 4'hD, 4'hD};
					2'b11: {red,green,blue} = {4'hF, 4'hF, 4'hF};
				endcase
			2'b01:
				if ({maze_red, maze_green, maze_blue} == 12'h000)
					{red,green,blue} = {maze_red, maze_green, maze_blue};
				else 
					{red,green,blue} = {color_red, color_green, color_blue};
			2'b10:
				case(rout)
					1'b1: {red,green,blue} = {4'hF, 4'h0, 4'h0}; 
					1'b0: {red,green,blue} = {4'hF, 4'hF, 4'hF};
				endcase
			2'b11:
				case(gout)
					1'b1: {red,green,blue} = {4'h0, 4'hF, 4'h0}; 
					1'b0: {red,green,blue} = {4'hF, 4'hF, 4'hF};
				endcase
		endcase
	end
								
endmodule
