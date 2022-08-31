module maze (input logic Clk,
				input logic [9:0] DrawX, DrawY,
				input logic [7:0] WALLS_DATA,
				input logic [7:0] WALLS_ADDR,
				input logic WALLS_WE,
				input logic [9:0] b1x, b1y, b2x, b2y, b3x, b3y, b4x, b4y, b5x, b5y, b6x, b6y,
				input logic [9:0] tank1x, tank1y, tank2x, tank2y,
				input logic [6:0] tank1angle, tank2angle,
				output logic [3:0] red, green, blue,
				output logic b1xwall, b1ywall, b2xwall, b2ywall, b3xwall, b3ywall, b4xwall, b4ywall, b5xwall, b5ywall, b6xwall, b6ywall,
				output logic tank1front, tank1back, tank2front, tank2back);
				
				
				
				
				
				
always_comb begin
					
	if (WALLS_WE)
		WALLS_VRAM[WALLS_ADDR] <= WALLS_DATA;
					
end
				
				
				
				
logic [7:0] WALLS_VRAM [34:0];
logic rwall, bwall, lwall, twall;
logic on_rwall, on_lwall, on_twall, on_bwall;
logic [3:0] wall;
logic [7:0] addr;
logic [7:0] baddr [5:0];
logic [3:0] bwalls [5:0];
logic bpos [5:0];

logic [3:0] tank1walls [6:0];
logic [7:0] tank1addr [6:0];
logic tank1pos [6:0];

logic [3:0] tank2walls [6:0];
logic [7:0] tank2addr [6:0];
logic tank2pos [6:0];

bullet_col bcol_arr[5:0] (.Clk(Clk),
		.x({b1x, b2x, b3x, b4x, b5x, b6x}),
		.y({b1y, b2y, b3y, b4y, b5y, b6y}),
		.wall(bwalls),
		.xcol({b1xwall, b2xwall, b3xwall, b4xwall, b5xwall, b6xwall}),
		.ycol({b1ywall, b2ywall, b3ywall, b4ywall, b5ywall, b6ywall}),
		.addr(baddr), .pos(bpos));
		
		
tank_col tank1col (.Clk(Clk),
				.center_x(tank1x), .center_y(tank1y),
				.angle(tank1angle),
				.wall(tank1walls),
				.front_col(tank1front), .back_col(tank1back),
				.addr(tank1addr),
				.pos(tank1pos));
			
			
tank_col tank2col (.Clk(Clk),
				.center_x(tank2x), .center_y(tank2y),
				.angle(tank2angle),
				.wall(tank2walls),
				.front_col(tank2front), .back_col(tank2back),
				.addr(tank2addr),
				.pos(tank2pos));
				

				
always_comb
begin
					
	/*WALLS_VRAM[0][3:0] = 4'hf;
	WALLS_VRAM[139][7:4] = 4'hf;
	//WALLS_VRAM[1:279] = 1116'b0;*/
				
					
				
	addr = (DrawY>>6)*5 + (DrawX>>7);
	wall = WALLS_VRAM[addr][(DrawX[6]*4)+:4];
	rwall = wall[3];
	bwall = wall[2];
	lwall = wall[1];
	twall = wall[0];
			
	//for each block, a wall is 1 pixel length, but since walls will be combined
	//(ie. right wall in one block is left wall in the block next to it), the walls
	//are technically 2 pixels wide
	on_rwall = (DrawX[5:0]>=62); //checks if the electron gun is pointing to right side of a block
	on_bwall = (DrawY[5:0]>=62); //checks bottom side
	on_lwall = (DrawX[5:0]<=1); //checks left side
	on_twall = (DrawY[5:0]<=1); //checks top side
		
	//if there is a wall present and the electron gun is pointing at that pixel of the block
	//then color is black, else color is white
	if ((on_rwall & rwall) | (on_twall & twall) | (on_bwall & bwall) | (on_lwall & lwall))
		{red,green,blue}=12'b0;
	else
		{red,green,blue}=12'hfff;
		
	bwalls[3'b000] = WALLS_VRAM[baddr[3'b000]][4*(bpos[3'b000])+:4];
	bwalls[3'b001] = WALLS_VRAM[baddr[3'b001]][4*(bpos[3'b001])+:4];
	bwalls[3'b010] = WALLS_VRAM[baddr[3'b010]][4*(bpos[3'b010])+:4];
	bwalls[3'b011] = WALLS_VRAM[baddr[3'b011]][4*(bpos[3'b011])+:4];
	bwalls[3'b100] = WALLS_VRAM[baddr[3'b100]][4*(bpos[3'b100])+:4];
	bwalls[3'b101] = WALLS_VRAM[baddr[3'b101]][4*(bpos[3'b101])+:4];
	
	tank1walls[3'b000] = WALLS_VRAM[tank1addr[3'b000]][4*(tank1pos[3'b000])+:4];
	tank1walls[3'b001] = WALLS_VRAM[tank1addr[3'b001]][4*(tank1pos[3'b001])+:4];
	tank1walls[3'b010] = WALLS_VRAM[tank1addr[3'b010]][4*(tank1pos[3'b010])+:4];
	tank1walls[3'b011] = WALLS_VRAM[tank1addr[3'b011]][4*(tank1pos[3'b011])+:4];
	tank1walls[3'b100] = WALLS_VRAM[tank1addr[3'b100]][4*(tank1pos[3'b100])+:4];
	tank1walls[3'b101] = WALLS_VRAM[tank1addr[3'b101]][4*(tank1pos[3'b101])+:4];
	tank1walls[3'b110] = WALLS_VRAM[tank1addr[3'b110]][4*(tank1pos[3'b110])+:4];
	
	tank2walls[3'b000] = WALLS_VRAM[tank2addr[3'b000]][4*(tank2pos[3'b000])+:4];
	tank2walls[3'b001] = WALLS_VRAM[tank2addr[3'b001]][4*(tank2pos[3'b001])+:4];
	tank2walls[3'b010] = WALLS_VRAM[tank2addr[3'b010]][4*(tank2pos[3'b010])+:4];
	tank2walls[3'b011] = WALLS_VRAM[tank2addr[3'b011]][4*(tank2pos[3'b011])+:4];
	tank2walls[3'b100] = WALLS_VRAM[tank2addr[3'b100]][4*(tank2pos[3'b100])+:4];
	tank2walls[3'b101] = WALLS_VRAM[tank2addr[3'b101]][4*(tank2pos[3'b101])+:4];
	tank2walls[3'b110] = WALLS_VRAM[tank2addr[3'b110]][4*(tank2pos[3'b110])+:4];

	
end
		
endmodule



		
		