module pos_edge_det (input sig, input clk, output pe);
reg d;
always @ (posedge clk) begin
	d <= sig;
end
assign pe = sig & ~d;
endmodule 