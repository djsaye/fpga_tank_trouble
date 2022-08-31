module clock_divider (input clk_in,
					input Reset,
					output clk_out);

logic [25:0] counter;
					
always_ff @ (posedge clk_in or posedge Reset )
    begin 
        if (Reset) begin
            counter <= 26'b0;
				clk_out <= 0;
        end else begin
				if (counter == 26'd49999999) begin
					clk_out <= ~ (clk_out);
					counter <= 26'b0;
				end else
					counter <= counter + 26'd1;
         end   
    end	
	
					
					
endmodule
