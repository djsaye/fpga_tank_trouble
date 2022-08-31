//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input        [9:0] tank1x, tank1y, tank2x, tank2y, b1x, b1y, b2x, b2y, b3x, b3y, b4x, b4y, b5x, b5y, b6x, b6y, 
							  input 			[9:0] drawx, drawy, drawt1x, drawt1y, drawt2x, drawt2y,
							  input			[1:0] greenscore, redscore,
                       output logic [3:0]  Red, Green, Blue );
    
    logic tank1_on, tank2_on, tank1gun, tank2gun, b_on;
	 logic [9:0] t1minusx, t1minusy, t1plusx, t1plusy;
	 logic [9:0] t2minusx, t2minusy, t2plusx, t2plusy;
//tank drawing
    always_comb
    begin:tank1_on_proc
        if ((drawt1x >= tank1x-7) &&
				(drawt1x <= tank1x+7) &&
				(drawt1y >= tank1y-7) &&
				(drawt1y <= tank1y+7))
            tank1_on = 1'b1;
        else 
            tank1_on = 1'b0;
    end 
    always_comb
    begin:tank2_on_proc
        if ((drawt2x >= tank2x-7) &&
				(drawt2x <= tank2x+7) &&
				(drawt2y >= tank2y-7) &&
				(drawt2y <= tank2y+7))
            tank2_on = 1'b1;
        else 
            tank2_on = 1'b0;
    end

//gun drawings
    always_comb
    begin:tank1g
        if ((drawt1x >= tank1x-1) &&
				(drawt1x <= tank1x+12) &&
				(drawt1y >= tank1y-2) &&
				(drawt1y <= tank1y+2))
            tank1gun = 1'b1;
        else 
            tank1gun = 1'b0;
    end 
    always_comb
    begin:tank2g
        if ((drawt2x >= tank2x-1) &&
				(drawt2x <= tank2x+12) &&
				(drawt2y >= tank2y-2) &&
				(drawt2y <= tank2y+2))
            tank2gun = 1'b1;
        else 
            tank2gun = 1'b0;
    end

//bullet drawings
int d1x, d1y, d2x, d2y, d3x, d3y, d4x, d4y, d5x, d5y, d6x, d6y, size;
assign size = 2;
assign d1x = drawx - b1x;
assign d1y = drawy - b1y;
assign d2x = drawx - b2x;
assign d2y = drawy - b2y;
assign d3x = drawx - b3x;
assign d3y = drawy - b3y;
assign d4x = drawx - b4x;
assign d4y = drawy - b4y;
assign d5x = drawx - b5x;
assign d5y = drawy - b5y;
assign d6x = drawx - b6x;
assign d6y = drawy - b6y;
    always_comb
	 begin
	 //bullet1
		if( ( d1x*d1x + d1y*d1y) <= (size * size))
         b_on = 1'b1;
      else if (( d2x*d2x + d2y*d2y) <= (size * size))
         b_on = 1'b1;
		else if (( d3x*d3x + d3y*d3y) <= (size * size))
         b_on = 1'b1;
		else if ( (d4x*d4x + d4y*d4y) <= (size * size))
         b_on = 1'b1;
		else if ( (d5x*d5x + d5y*d5y) <= (size * size))
         b_on = 1'b1;
		else if ( (d6x*d6x + d6y*d6y) <= (size * size))
         b_on = 1'b1;
		else
			b_on =1'b0;
	 end
//draw symbols
logic score;
always_comb
begin
	if(redscore>=2'b01 & (drawy >= 9'd456) & (drawy <= 9'd472) & (drawx==200|drawx==201))
		score = 1;
	else if(redscore==2'b10 & (drawy >= 9'd456) & (drawy <= 9'd472) & (drawx==210|drawx==211))
		score = 1;
	else if(greenscore>=2'b01 & (drawy >= 9'd456) & (drawy <= 9'd472) & (drawx==440|drawx==439))
		score = 1;
	else if(greenscore==2'b10 & (drawy >= 9'd456) & (drawy <= 9'd472) & (drawx==430|drawx==429))
		score = 1;
	else
		score = 0;
end
	 
//RGB
    always_comb
    begin:RGB_Display
		  if (tank1gun | tank2gun)
		  begin
				Red = 4'h0;
            Green = 4'h0;
            Blue = 4'h0;
        end else if ( b_on | score ) //bullet on
		  begin
				Red = 4'h0;
            Green = 4'h0;
            Blue = 4'h0;
		  end
		  else if (tank1_on ) 
        begin 
            Red = 4'hf;
            Green = 4'h0;
            Blue = 4'h0;
        end else if( tank2_on )
		  begin
				Red = 4'h0;
            Green = 4'hF;
            Blue = 4'h0;
		  end
        else 
        begin 
            Red = 4'hF; 
            Green = 4'hF;
            Blue = 4'hF;
        end 		  
    end 
    
endmodule
