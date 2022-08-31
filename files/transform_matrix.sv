module transform_matrix (input [9:0] x, y, 
								 input [9:0] rot_pointx, rot_pointy,
								 input [6:0] angle,
								 output [9:0] x_out, y_out);
//INPUTS SHOULD ONLY BE POSITIVE
							 
//use transformation matrix to change the direction the tank is facing
//found here: https://stackoverflow.com/questions/6645093/how-to-rotate-a-group-of-2d-shapes-around-an-arbitrary-point
//fixed point mult

//get angle wanted and sign extend
logic [8:0] sin, cos;
logic [19:0] ext_sin, ext_cos;
trig calculator (.angle(angle), .sin(sin), .cos(cos));
assign ext_sin = {6'b000000, sin[7:0], 6'b000000};
assign ext_cos = {6'b000000, cos[7:0], 6'b000000};
//subtract the rot_point from curr point
logic signx, signy; //sign of the (x/y - px/y)
logic [19:0] subx, suby; // (x/y - px/y)
always_comb
begin
	if (rot_pointx > x)
	begin
			signx = 1;
			subx = {rot_pointx-x, 10'b000000000};
	end else
	begin
			signx = 0;
			subx = {x-rot_pointx, 10'b000000000};
	end
	if (rot_pointy > y)
	begin
			signy = 1;
			suby = {rot_pointy-y, 10'b000000000};
	end else
	begin
			signy = 0;
			suby = {y-rot_pointy, 10'b000000000};
	end
end

//we do multiplying first and slice it so we can add later	
logic [39:0] temp1, temp2, temp3, temp4, tempx, tempy;
logic sign1, sign2, sign3, sign4;
assign temp1 = subx*ext_cos;
assign temp2 = suby*ext_sin;
assign temp3 = subx*ext_sin;
assign temp4 = suby*ext_cos;	
assign sign1 = signx^cos[8];
assign sign2 = signy^sin[8];
assign sign3 = signx^sin[8];
assign sign4 = signy^cos[8];

//sum all the values together
assign tempx = ({rot_pointx, 20'h0} + (sign1 ? (~temp1)+1 : temp1) + (sign2 ? temp2 : (~temp2)+1));
assign tempy = ({rot_pointy, 20'h0} + (sign3 ? (~temp3)+1 : temp3) + (sign4 ? (~temp4)+1 : temp4));
assign x_out = {tempx[29:21],tempx[20]|tempx[19]};
assign y_out = {tempy[29:21],tempy[20]|tempy[19]};

endmodule 