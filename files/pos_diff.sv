module pos_diff(input [9:0] num1, num2,
					 output [9:0] diff);
always_comb
begin
	if(num1 >= num2)
		diff = num1 - num2;
   else
		diff = num2 - num1; 
end
endmodule 