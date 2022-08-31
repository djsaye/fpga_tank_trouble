FPGA Tank Trouble Final Project - Satvik Yellanki, Andrew Li


Running the Project:
	To run our project, first ensure that there is a VGA monitor and keyboard connected to the FPGA
to use the proper I/O. Then perform a full compilation of the project in Quartus. Once the
compilattion is complete, go to the programmer tab in Quartus and select the USB Blaster as the
hardware option and click Start to run the program. Then go into Tools and open the Eclipse
IDE. Once the Tank_Trouble_app and Tank_Trouble_app_bsp projects load, generate the Nios II BSP
for the Tank_Trouble_app_bsp.Then create the run configuration in eclipse with the Tank_Trouble
.elf file and the USB Blaster as the Target Connection. Then run the configuration. 

Playing the Game:
	Follow the instruction on the screen and press Space to run the game. There is a red and green
tank which each have 3 bullets. For the tank on the bottom right (tank 1), the controls are up, down
arrow keys to move forward and backward, then right, left arrow keys to rotate the tank. For the tank
on the top left (tank 2), the controls are W, S to move forward and backward, then A, D to rotate the
tank. For tank 1, to shoot, you should press the Enter key, and the 'Q' key for tank 2. While each
player only has 3 bullets, each bullet will regenerate back after approximatley 10 seconds for the
player to shoot again. Once a tank gets shot, the other tank will get one point which will be
represented as a tally in the bottom of the screen. Once a player gets 3 points, the game ends and the
end screen showing which player won will be shown. Then press Space key to go back to the start screen
to start a new game.