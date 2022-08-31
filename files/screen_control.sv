module screen_control(input reset, redwin, greenwin, clk,
							 input [7:0] keycode,
							 output screenreset,
							 output [1:0] redscore, greenscore,
							 output [1:0] currstate);
//00: start    01: game     10: red wins   11: green wins

enum logic [4:0] {start, game00, game10, game20, game01, game02, game11, game12, game21, game22,
						reset10, reset20, reset01, reset02, reset11, reset12, reset21, reset22,
						redwins, greenwins} State, Next_state;

always_ff @ (posedge clk or posedge reset)
	begin
		if (reset)
			State <= start;
		else 
			State <= Next_state;
	end

//next state logic
logic space, pos_edge;
pos_edge_det space_det (.sig(space), .clk(clk), .pe(pos_edge));
always_comb
begin
	if (keycode == 8'h2c)
		space = 1;
	else
		space = 0;
end
always_comb
begin
	unique case (State)
		start : 
		if (keycode == 8'h2c & pos_edge)
			Next_state = game00;
		else
			Next_state = start;
		//game states
		game00 :
		if (redwin)
			Next_state = reset10;
		else if (greenwin)
			Next_state = reset01;
		else
			Next_state = game00;
		game10 :
		if (redwin)
			Next_state = reset20;
		else if (greenwin)
			Next_state = reset11;
		else
			Next_state = game10;
		game01 :
		if (redwin)
			Next_state = reset11;
		else if (greenwin)
			Next_state = reset02;
		else
			Next_state = game01;
		game11 :
		if (redwin)
			Next_state = reset21;
		else if (greenwin)
			Next_state = reset12;
		else
			Next_state = game11;
		
		game20 :
		if (redwin)
			Next_state = redwins;
		else if (greenwin)
			Next_state = reset21;
		else
			Next_state = game20;
		game02 :
		if (redwin)
			Next_state = reset12;
		else if (greenwin)
			Next_state = greenwins;
		else
			Next_state = game02;
		game21 :
		if (redwin)
			Next_state = redwins;
		else if (greenwin)
			Next_state = reset22;
		else
			Next_state = game21;
		game12 :
		if (redwin)
			Next_state = reset22;
		else if (greenwin)
			Next_state = greenwins;
		else
			Next_state = game12;
		game22 :
		if (redwin)
			Next_state = redwins;
		else if (greenwin)
			Next_state = greenwins;
		else
			Next_state = game22;
		//resetstates
		reset01: Next_state = game01;
		reset02: Next_state = game02;
		reset10: Next_state = game10;
		reset20: Next_state = game20;
		reset11: Next_state = game11;
		reset21: Next_state = game21;
		reset12: Next_state = game12;
		reset22: Next_state = game22;
		redwins: 
		if (keycode == 8'h2c & pos_edge)
			Next_state = start;
		else
			Next_state = redwins;
		greenwins:
		if (keycode == 8'h2c & pos_edge)
			Next_state = start;
		else
			Next_state = greenwins;
		default : ;
	endcase 
//output per state
	screenreset = 1;
	redscore = 0;
	greenscore = 0;
	case (State)
		start: currstate = 2'b00;
		game00:
		begin
			currstate = 2'b01;
			screenreset = 0;
		end
		game10:
		begin
			currstate = 2'b01;
			screenreset = 0;
			redscore = 2'b01;
		end
		game20:
		begin
			currstate = 2'b01;
			screenreset = 0;
			redscore = 2'b10;
		end
		game01:
		begin
			currstate = 2'b01;
			screenreset = 0;
			greenscore = 2'b01;
		end
		game02:
		begin
			currstate = 2'b01;
			screenreset = 0;
			greenscore = 2'b10;
		end
		game11:
		begin
			currstate = 2'b01;
			screenreset = 0;
			redscore = 2'b01;
			greenscore = 2'b01;
		end
		game21:
		begin
			currstate = 2'b01;
			screenreset = 0;
			redscore = 2'b10;
			greenscore = 2'b01;
		end
		game12:
		begin
			currstate = 2'b01;
			screenreset = 0;
			redscore = 2'b01;
			greenscore = 2'b10;
		end
		game22:
		begin
			currstate = 2'b01;
			screenreset = 0;
			redscore = 2'b10;
			greenscore = 2'b10;
		end
		reset01 : currstate = 2'b01;
		reset02 : currstate = 2'b01;
		reset10 : currstate = 2'b01;
		reset20 : currstate = 2'b01;
		reset11 : currstate = 2'b01;
		reset12 : currstate = 2'b01;
		reset21 : currstate = 2'b01;
		reset22 : currstate = 2'b01;
		redwins: currstate = 2'b10;
		greenwins: currstate = 2'b11;
		default : currstate = 2'b00;
	endcase
end
endmodule 