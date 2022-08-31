//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 62                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module Tank_Trouble_TL (

      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, vssig, blank, sync, VGA_Clk;


//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawx, drawy, ballxsig, ballysig, ballsizesig;
	logic [3:0] Red, Blue, Green;
	logic [7:0] keycode1, keycode2,keycode3,keycode4,keycode5,keycode6;
	logic [7:0] WALLS_DATA, WALLS_ADDR;
	logic clk_1hz;
	logic WALLS_WE;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//set colors with blank
	always_ff @ (posedge VGA_Clk)
	begin
		if(blank)
		begin
			VGA_R <= Red;
			VGA_B <= Blue;
			VGA_G <= Green;
		end else
		begin
			VGA_R <= 0;
			VGA_B <= 0;
			VGA_G <= 0;
		end
	end 
	
	Tank_Trouble_soc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR}),
		.keycode1_export(keycode1),
		.keycode2_export(keycode2),
		.keycode3_export(keycode3),
		.keycode4_export(keycode4),
		.keycode5_export(keycode5),
		.keycode6_export(keycode6),
		
		//Walls writing, these values are edited in C code to write walls
		.walls_data_export(WALLS_DATA), //1st bit is write signal, next 9 are address, last 4 value
		.walls_addr_export(WALLS_ADDR),
		.walls_we_export(WALLS_WE),
		
		.screen_reset_export(screen_reset & ~screenreset_pe)
		
	 );


//instantiate a vga_controller, ball, and color_mapper here with the ports.
//trig calculation
logic [9:0] drawt1x, drawt1y, drawt2x, drawt2y;
logic [6:0] t1angle, t2angle;
logic [8:0] sint1, cost1, sint2, cost2;
//tank location signals
logic [9:0] tank1x, tank1y, tank2x, tank2y;
//local bullet vars
logic [9:0] b1x, b1y, b2x, b2y, b3x, b3y, b4x, b4y, b5x, b5y, b6x, b6y;
logic b1shot, b2shot, b3shot, b4shot, b5shot, b6shot;
logic trigger1, trigger2, trigger3, trigger4, trigger5, trigger6;
logic b1xwall, b1ywall, b2xwall, b2ywall, b3xwall, b3ywall, b4xwall, b4ywall, b5xwall, b5ywall, b6xwall, b6ywall;
logic tank1front, tank1back, tank2front, tank2back;

//bullet instance
bullet bullet1(.xwall(b1xwall), .ywall(b1ywall), .fclk(MAX10_CLK1_50),
					.trigger(trigger1), .reset(screen_reset|Reset_h), .frame_clk(VGA_VS),
					.angleshot(t1angle), .xshot(tank1x), .yshot(tank1y), .x_start(10'd30),
					.x(b1x), .y(b1y), .shot(b1shot), .timer_clk(clk_1hz));
					
bullet bullet2(.xwall(b2xwall), .ywall(b2ywall), .fclk(MAX10_CLK1_50),
					.trigger(trigger2), .reset(screen_reset|Reset_h), .frame_clk(VGA_VS),
					.angleshot(t1angle), .xshot(tank1x), .yshot(tank1y), .x_start(10'd20),
					.x(b2x), .y(b2y), .shot(b2shot), .timer_clk(clk_1hz));
					
bullet bullet3(.xwall(b3xwall), .ywall(b3ywall), .fclk(MAX10_CLK1_50),
					.trigger(trigger3), .reset(screen_reset|Reset_h), .frame_clk(VGA_VS),
					.angleshot(t1angle), .xshot(tank1x), .yshot(tank1y), .x_start(10'd10),
					.x(b3x), .y(b3y), .shot(b3shot), .timer_clk(clk_1hz));
					
bullet bullet4(.xwall(b4xwall), .ywall(b4ywall), .fclk(MAX10_CLK1_50),
					.trigger(trigger4), .reset(screen_reset|Reset_h), .frame_clk(VGA_VS),
					.angleshot(t2angle), .xshot(tank2x), .yshot(tank2y), .x_start(10'd630),
					.x(b4x), .y(b4y), .shot(b4shot), .timer_clk(clk_1hz));
					
bullet bullet5(.xwall(b5xwall), .ywall(b5ywall), .fclk(MAX10_CLK1_50),
					.trigger(trigger5), .reset(screen_reset|Reset_h), .frame_clk(VGA_VS), 
					.angleshot(t2angle), .xshot(tank2x), .yshot(tank2y), .x_start(10'd620),
					.x(b5x), .y(b5y), .shot(b5shot), .timer_clk(clk_1hz));
					
bullet bullet6(.xwall(b6xwall), .ywall(b6ywall), .fclk(MAX10_CLK1_50),
					.trigger(trigger6), .reset(screen_reset|Reset_h), .frame_clk(VGA_VS),
					.angleshot(t2angle), .xshot(tank2x), .yshot(tank2y), .x_start(10'd610),
					.x(b6x), .y(b6y), .shot(b6shot), .timer_clk(clk_1hz));

//logic for a bullet being shot. bullets 1-3 are from tank1, 4-6 are tank 2
logic [5:0] t1shot, t2shot, post1, post2;
pos_edge_det det1(.sig(t1shot[0]), .clk(VGA_VS), .pe(post1[0])); 
pos_edge_det det2(.sig(t1shot[1]), .clk(VGA_VS), .pe(post1[1])); 
pos_edge_det det3(.sig(t1shot[2]), .clk(VGA_VS), .pe(post1[2])); 
pos_edge_det det4(.sig(t1shot[3]), .clk(VGA_VS), .pe(post1[3])); 
pos_edge_det det5(.sig(t1shot[4]), .clk(VGA_VS), .pe(post1[4])); 
pos_edge_det det6(.sig(t1shot[5]), .clk(VGA_VS), .pe(post1[5])); 
pos_edge_det det7(.sig(t2shot[0]), .clk(VGA_VS), .pe(post2[0])); 
pos_edge_det det8(.sig(t2shot[1]), .clk(VGA_VS), .pe(post2[1])); 
pos_edge_det det9(.sig(t2shot[2]), .clk(VGA_VS), .pe(post2[2])); 
pos_edge_det det10(.sig(t2shot[3]), .clk(VGA_VS), .pe(post2[3])); 
pos_edge_det det11(.sig(t2shot[4]), .clk(VGA_VS), .pe(post2[4])); 
pos_edge_det det12(.sig(t2shot[5]), .clk(VGA_VS), .pe(post2[5]));
always_ff @ (posedge VGA_VS)
begin
	case(keycode1)
		8'h14 : begin 
		t1shot[0] <= 1;
		t2shot[0] <= 0;
		end
		8'h28 : begin
		t2shot[0] <= 1;
		t1shot[0] <= 0;
		end
		default : begin 
			t1shot[0] <= 0;
			t2shot[0] <= 0; 
		end
	endcase
	case(keycode2)
		8'h14: begin 
		t1shot[1] <= 1;
		t2shot[1] <= 0;
		end
		8'h28: begin
		t2shot[1] <= 1;
		t1shot[1] <= 0;
		end
		default: 
		begin 
			t1shot[1] <= 0;
			t2shot[1] <= 0; 
		end
	endcase
	case(keycode3)
		8'h14: begin 
		t1shot[2] <= 1;
		t2shot[2] <= 0;
		end
		8'h28: begin
		t2shot[2] <= 1;
		t1shot[2] <= 0;
		end
		default: 
		begin 
			t1shot[2] <= 0;
			t2shot[2] <= 0; 
		end
	endcase
	case(keycode4)
		8'h14: begin 
		t1shot[3] <= 1;
		t2shot[3] <= 0;
		end
		8'h28: begin
		t2shot[3] <= 1;
		t1shot[3] <= 0;
		end
		default: 
		begin 
			t1shot[3] <= 0;
			t2shot[3] <= 0; 
		end
	endcase
	case(keycode5)
		8'h14: begin 
		t1shot[4] <= 1;
		t2shot[4] <= 0;
		end
		8'h28: begin
		t2shot[4] <= 1;
		t1shot[4] <= 0;
		end
		default: 
		begin 
			t1shot[4] <= 0;
			t2shot[4] <= 0; 
		end
	endcase
	case(keycode6)
		8'h14: begin 
		t1shot[5] <= 1;
		t2shot[5] <= 0;
		end
		8'h28: begin
		t2shot[5] <= 1;
		t1shot[5] <= 0;
		end
		default: 
		begin 
			t1shot[5] <= 0;
			t2shot[5] <= 0; 
		end
	endcase
	if(post1 != 0)
	begin
		if(~b1shot)
			trigger1 <= 1;
		else if (~b2shot)
			trigger2 <= 1;
		else if (~b3shot)
			trigger3 <= 1; 
	end else
	begin
		trigger1 <= 0;
		trigger2 <= 0;
		trigger3 <= 0;
	end
	if(post2 != 0)
	begin
		if(~b4shot)
			trigger4 <= 1;
		else if (~b5shot)
			trigger5 <= 1;
		else if (~b6shot)
			trigger6 <= 1; 
	end else
	begin
		trigger4 <= 0;
		trigger5 <= 0;
		trigger6 <= 0;
	end
end

vga_controller vga (.Clk(MAX10_CLK1_50), .Reset(Reset_h), .hs(VGA_HS), .vs(VGA_VS), 
						  .pixel_clk(VGA_Clk), .blank(blank), .sync(sync), .DrawX(drawx),
						  .DrawY(drawy)); 
						
//calculate draw values based on rotation		
transform_matrix t1 (.x(drawx), .y(drawy), .rot_pointx(tank1x), .rot_pointy(tank1y), .angle(t1angle),
							.x_out(drawt1x), .y_out(drawt1y));
transform_matrix t2 (.x(drawx), .y(drawy), .rot_pointx(tank2x), .rot_pointy(tank2y), .angle(t2angle),
							.x_out(drawt2x), .y_out(drawt2y));

tank_one tank1 (.Reset(screen_reset|Reset_h), .frame_clk(VGA_VS),
				 .port_0(keycode1), .port_1(keycode2), .port_2(keycode3),
				 .port_3(keycode4), .port_4(keycode5), .port_5(keycode6),
				 .tank_x(tank1x), .tank_y(tank1y), .tank_angle(t1angle),
				 .front_col(tank1front), .back_col(tank1back));
				 
tank_two tank2 (.Reset(screen_reset|Reset_h), .frame_clk(VGA_VS),
				 .port_0(keycode1), .port_1(keycode2), .port_2(keycode3),
				 .port_3(keycode4), .port_4(keycode5), .port_5(keycode6),
				 .tank_x(tank2x), .tank_y(tank2y), .tank_angle(t2angle),
				 .front_col(tank2front), .back_col(tank2back));
				 
clock_divider clkdiv(.Reset(Reset_h), .clk_in(MAX10_CLK1_50), .clk_out(clk_1hz));
 

//screen control
logic redwin, greenwin;
logic [1:0] screen, greenscore, redscore;
logic screen_reset;

screen_control controller (.reset(Reset_h), .redwin(redwin), .greenwin(greenwin), .clk(VGA_VS),
							      .keycode(keycode1), .currstate(screen), .screenreset(screen_reset),
									.redscore(redscore), .greenscore(greenscore));
									
pos_edge_det screenreset_det(.sig(screenreset), .clk(VGA_VS), .pe(screenreset_pe));
									
death dies (.t1x(tank1x), .t1y(tank1y), .t2x(tank2x), .t2y(tank2y),
				.b1x(b1x), .b1y(b1y), .b2x(b2x), .b2y(b2y), .b3x(b3x), .b3y(b3y), 
				.b4x(b4x), .b4y(b4y), .b5x(b5x), .b5y(b5y), .b6x(b6x), .b6y(b6y),
				.redL(redwin), .greenL(greenwin));

//drawing logic
logic [3:0] cmapRed, cmapBlue, cmapGreen, mazeRed, mazeBlue, mazeGreen;	 				 
color_mapper color (.tank1x(tank1x), .tank1y(tank1y), .tank2x(tank2x), .b1x(b1x), .b1y(b1y),
						  .b2x(b2x), .b2y(b2y), .b3x(b3x), .b3y(b3y), .b4x(b4x), .b4y(b4y), .b5x(b5x), .b5y(b5y),
						  .b6x(b6x), .b6y(b6y), .tank2y(tank2y), .drawx(drawx), .drawy(drawy), 
					     .drawt1x(drawt1x), .drawt1y(drawt1y), .drawt2x(drawt2x), .drawt2y(drawt2y),
						  .greenscore(greenscore), .redscore(redscore),
                    .Red(cmapRed), .Green(cmapGreen), .Blue(cmapBlue));

maze maze_draw (.Clk(MAX10_CLK1_50), .DrawX(drawx), .DrawY(drawy), .red(mazeRed), .green(mazeGreen), .blue(mazeBlue),
					 .WALLS_ADDR(WALLS_ADDR), .WALLS_WE(WALLS_WE), .WALLS_DATA(WALLS_DATA),
					 .b1x(b1x), .b1y(b1y), .b2x(b2x), .b2y(b2y), .b3x(b3x), .b3y(b3y),
					 .b4x(b4x), .b4y(b4y), .b5x(b5x), .b5y(b5y), .b6x(b6x), .b6y(b6y),
					 .b1xwall(b1xwall), .b1ywall(b1ywall),.b2xwall(b2xwall), .b2ywall(b2ywall),
					 .b3xwall(b3xwall), .b3ywall(b3ywall),.b4xwall(b4xwall), .b4ywall(b4ywall),
					 .b5xwall(b5xwall), .b5ywall(b5ywall),.b6xwall(b6xwall), .b6ywall(b6ywall),
					 .tank1x(tank1x), .tank1y(tank1y), .tank2x(tank2x), .tank2y(tank2y), .tank1angle(t1angle), .tank2angle(t2angle),
					 .tank1front(tank1front), .tank1back(tank1back), .tank2front(tank2front), .tank2back(tank2back));
					 
					 
priority_encoder p (.color_red(cmapRed), .color_green(cmapGreen), .color_blue(cmapBlue), 
					     .maze_red(mazeRed), .maze_green(mazeGreen), .maze_blue(mazeBlue), .screen(screen),
						  .clk(MAX10_CLK1_50), .drawx(drawx), .drawy(drawy),
				        .red(Red), .green(Green), .blue(Blue));						  
						  
endmodule
