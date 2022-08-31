//ECE 385 USB Host Shield code
//based on Circuits-at-home USB Host code 1.x
//to be used for ECE 385 course materials
//Revised October 2020 - Zuofu Cheng

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include "../Tank_Trouble_app_bsp/system.h"
#include "../Tank_Trouble_app_bsp/drivers/inc/altera_avalon_spi.h"
#include "../Tank_Trouble_app_bsp/drivers/inc/altera_avalon_spi_regs.h"
#include "../Tank_Trouble_app_bsp/drivers/inc/altera_avalon_pio_regs.h"
#include "../Tank_Trouble_app_bsp/HAL/inc/sys/alt_irq.h"
#include "usb_kb/GenericMacros.h"
#include "usb_kb/GenericTypeDefs.h"
#include "usb_kb/HID.h"
#include "usb_kb/MAX3421E.h"
#include "usb_kb/transfer.h"
#include "usb_kb/usb_ch9.h"
#include "usb_kb/USB.h"

extern HID_DEVICE hid_device;

static BYTE addr = 1; 				//hard-wired USB address
const char* const devclasses[] = { " Uninitialized", " HID Keyboard", " HID Mouse", " Mass storage" };

BYTE GetDriverandReport() {
	BYTE i;
	BYTE rcode;
	BYTE device = 0xFF;
	BYTE tmpbyte;

	DEV_RECORD* tpl_ptr;
	printf("Reached USB_STATE_RUNNING (0x40)\n");
	for (i = 1; i < USB_NUMDEVICES; i++) {
		tpl_ptr = GetDevtable(i);
		if (tpl_ptr->epinfo != NULL) {
			printf("Device: %d", i);
			printf("%s \n", devclasses[tpl_ptr->devclass]);
			device = tpl_ptr->devclass;
		}
	}
	//Query rate and protocol
	rcode = XferGetIdle(addr, 0, hid_device.interface, 0, &tmpbyte);
	if (rcode) {   //error handling
		printf("GetIdle Error. Error code: ");
		printf("%x \n", rcode);
	} else {
		printf("Update rate: ");
		printf("%x \n", tmpbyte);
	}
	printf("Protocol: ");
	rcode = XferGetProto(addr, 0, hid_device.interface, &tmpbyte);
	if (rcode) {   //error handling
		printf("GetProto Error. Error code ");
		printf("%x \n", rcode);
	} else {
		printf("%d \n", tmpbyte);
	}
	return device;
}

void setLED(int LED) {
	IOWR_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE,
			(IORD_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE) | (0x001 << LED)));
}

void clearLED(int LED) {
	IOWR_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE,
			(IORD_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE) & ~(0x001 << LED)));

}

void printSignedHex0(signed char value) {
	BYTE tens = 0;
	BYTE ones = 0;
	WORD pio_val = IORD_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE);
	if (value < 0) {
		setLED(11);
		value = -value;
	} else {
		clearLED(11);
	}
	//handled hundreds
	if (value / 100)
		setLED(13);
	else
		clearLED(13);

	value = value % 100;
	tens = value / 10;
	ones = value % 10;

	pio_val &= 0x00FF;
	pio_val |= (tens << 12);
	pio_val |= (ones << 8);

	IOWR_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE, pio_val);
}

void printSignedHex1(signed char value) {
	BYTE tens = 0;
	BYTE ones = 0;
	DWORD pio_val = IORD_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE);
	if (value < 0) {
		setLED(10);
		value = -value;
	} else {
		clearLED(10);
	}
	//handled hundreds
	if (value / 100)
		setLED(12);
	else
		clearLED(12);

	value = value % 100;
	tens = value / 10;
	ones = value % 10;
	tens = value / 10;
	ones = value % 10;

	pio_val &= 0xFF00;
	pio_val |= (tens << 4);
	pio_val |= (ones << 0);

	IOWR_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE, pio_val);
}

void setKeycode(int addr, WORD keycode)
{
	IOWR_ALTERA_AVALON_PIO_DATA(addr, keycode);
}

void setWall(BYTE addr, BYTE value) {

	IOWR_ALTERA_AVALON_PIO_DATA(WALLS_ADDR_BASE, addr); //set addr value

	IOWR_ALTERA_AVALON_PIO_DATA(WALLS_DATA_BASE, value); //set data value

	IOWR_ALTERA_AVALON_PIO_DATA(WALLS_WE_BASE, 1); //set write to high

	IOWR_ALTERA_AVALON_PIO_DATA(WALLS_WE_BASE, 0); //set write to low


}

void generateMaze(time_t seed_double) {
	/*struct timeval time;
	gettimeofday(&time, NULL);
	srandom(time.tv_sec + time.tv_usec * 1000000ul);*/

	int seed_selector = ((int) seed_double) % 4;


	//22345621  24468785 20877667 29859857
	int seed = 29859857;

	if (seed_selector == 2) {
		seed = 20877667;
	} else if (seed_selector == 3) {
		seed = 24468785;
	} else if (seed_selector == 1) {
		seed = 22345621;
	}

	srand(seed);
	printf("Drawing Maze...\n");
		BOOL right[70];
		BOOL bottom[70];

		for (BYTE y=0; y<7; y++) { //draws border
			for (BYTE x=0; x<5; x++) {

				BYTE wall_val = 0;
				if(x==4) {//right wall
					wall_val += 128;
					right[y*10 + 2*x] = 0;
					//wall_val = 8*right[y*20 + 2*x];
				} else {
					if(rand() & 1) {
						right[y*10 + 2*x] = 1;
						right[y*10 + 2*x+1] = 0;
					} else {
						right[y*10 + 2*x] = 0;
						right[y*10 + 2*x+1] = (rand() & 1);
					}
					wall_val += (128*right[y*10 + 2*x+1] + 8*right[y*10 + 2*x]);
				}

				if(y==6)//bottom wall
					wall_val += (64+4);
				else {
					if(rand() & 1) {
						bottom[y*10 + 2*x] = 1;
						bottom[y*10 + 2*x+1] = 0;
					} else {
						bottom[y*10 + 2*x] = 0;
						bottom[y*10 + 2*x+1] = (rand() & 1);
					}
					wall_val += (64*bottom[y*10 + 2*x+1] + 4*bottom[y*10 + 2*x]);
				}

				if(x==0) //left wall
					wall_val += (2 + 32*right[y*10]);
				else
					wall_val += (32*right[y*10 + 2*x] + 2*right[y*10 + 2*x - 1]);

				if(y==0)//top wall
					wall_val += 17;
				else
					wall_val += (bottom[(y-1)*10 + 2*x] + 16*bottom[(y-1)*10 + 2*x + 1]);


				setWall(y*5 + x, wall_val);
			}
		}
}

int main() {
	BYTE rcode;
	BOOT_MOUSE_REPORT buf;		//USB mouse report
	BOOT_KBD_REPORT kbdbuf;
	volatile unsigned int *RESET = (unsigned int*) KEY_BASE;

	BYTE runningdebugflag = 0;//flag to dump out a bunch of information when we first get to USB_STATE_RUNNING
	BYTE errorflag = 0; //flag once we get an error device so we don't keep dumping out state info
	BYTE device;
	WORD keycode;

	printf("initializing MAX3421E...\n");
	MAX3421E_init();
	printf("initializing USB...\n");
	USB_init();

	time_t *start = time(NULL);

	generateMaze(start);
	while (1) {
		BOOL screen_reset = IORD_ALTERA_AVALON_PIO_DATA(SCREEN_RESET_BASE);
		if (screen_reset) {

			generateMaze(time(NULL));
			usleep(5000);
		}


		printf(".");
		MAX3421E_Task();
		USB_Task();
		//usleep (500000);
		if (GetUsbTaskState() == USB_STATE_RUNNING) {
			if (!runningdebugflag) {
				runningdebugflag = 1;
				setLED(9);
				device = GetDriverandReport();
			} else if (device == 1) {
				//run keyboard debug polling
				rcode = kbdPoll(&kbdbuf);
				if (rcode == hrNAK) {
					continue; //NAK means no new data
				} else if (rcode) {
					printf("Rcode: ");
					printf("%x \n", rcode);
					continue;
				}
				printf("keycodes: ");
				for (int i = 0; i < 6; i++) {
					printf("%x ", kbdbuf.keycode[i]);
				}
				setKeycode(KEYCODE1_BASE,kbdbuf.keycode[0]);
				setKeycode(KEYCODE2_BASE,kbdbuf.keycode[1]);
				setKeycode(KEYCODE3_BASE,kbdbuf.keycode[2]);
				setKeycode(KEYCODE4_BASE,kbdbuf.keycode[3]);
				setKeycode(KEYCODE5_BASE,kbdbuf.keycode[4]);
				setKeycode(KEYCODE6_BASE,kbdbuf.keycode[5]);
				printSignedHex0(kbdbuf.keycode[0]);
				printSignedHex1(kbdbuf.keycode[1]);
				printf("\n");
			}

			else if (device == 2) {
				rcode = mousePoll(&buf);
				if (rcode == hrNAK) {
					//NAK means no new data
					continue;
				} else if (rcode) {
					printf("Rcode: ");
					printf("%x \n", rcode);
					continue;
				}
				printf("X displacement: ");
				printf("%d ", (signed char) buf.Xdispl);
				printSignedHex0((signed char) buf.Xdispl);
				printf("Y displacement: ");
				printf("%d ", (signed char) buf.Ydispl);
				printSignedHex1((signed char) buf.Ydispl);
				printf("Buttons: ");
				printf("%x\n", buf.button);
				if (buf.button & 0x04)
					setLED(2);
				else
					clearLED(2);
				if (buf.button & 0x02)
					setLED(1);
				else
					clearLED(1);
				if (buf.button & 0x01)
					setLED(0);
				else
					clearLED(0);
			}
		} else if (GetUsbTaskState() == USB_STATE_ERROR) {
			if (!errorflag) {
				errorflag = 1;
				clearLED(9);
				printf("USB Error State\n");
				//print out string descriptor here
			}
		} else //not in USB running state
		{

			printf("USB task state: ");
			printf("%x\n", GetUsbTaskState());
			if (runningdebugflag) {	//previously running, reset USB hardware just to clear out any funky state, HS/FS etc
				runningdebugflag = 0;
				MAX3421E_init();
				USB_init();
			}
			errorflag = 0;
			clearLED(9);
		}

	}
	return 0;
}
