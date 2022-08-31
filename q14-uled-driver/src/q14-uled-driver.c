/*
 * The LEDs on the Motorola Q14 are controlled by a microcontroller
 * attached to the main soc's 2nd uart controller (/dev/ttyMSM1).
 *
 * From the OEM documentation:
 *
 * 	Led is controlled by MCU
 * 	MCU command is received from uart1
 * 	The color is set by RGB value
 * 	The command is combined with R+G+B+exam code
 * 	exam code is the sum of R+G+B then use the lower 2 bytes
 * 	examples:
 * 	set it to yellow (0xff+0xff=0x1fe)
 * 	echo -ne "\xff\xff\x0\xfe" > /dev/ttyMSM1
 *
 * In order to make the leds easier to manage, this userspace
 * driver utilizes the kernel's uleds driver to implement standard
 * LED class devices for red, green, and blue such that normal sysfs
 * nodes can be used to control their brightness and triggers.
 *
 * The select statement waits for brightness change reports from the
 * kernel, and then sets the current brightness values by writing
 * them to the uart as described above.
 *
 */ 

#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/select.h>

#include "uleds.h"

struct q14_uled {
	struct uleds_user_dev uled;
	int fd;
	int current_brightness;
};

#define NUM_LEDS 3

int main(int argc, char const *argv[])
{
	struct q14_uled leds[NUM_LEDS] = {
			{
			  .uled.name = "red",
			  .uled.max_brightness = 255,
			  .fd = -1,
			  .current_brightness = 0
			},
			{
			  .uled.name = "green",
			  .uled.max_brightness = 255,
			  .fd = -1,
			  .current_brightness = 0
			},
			{
			  .uled.name = "blue",
			  .uled.max_brightness = 255,
			  .fd = -1,
			  .current_brightness = 0
			},
	};

	struct timespec ts;
	fd_set master;
	int ret, i, ser_fd, max_fd = -1;
	char buf[4];

	FD_ZERO(&master);

	/*
	 * Register each color with the kernel's uleds driver.
	 * Also add its file descriptor to the master set and
	 * max_fd for use with select later.
	 * 
	 */
	for(i = 0; i < NUM_LEDS; i++) {
		leds[i].fd = open("/dev/uleds", O_RDWR);
		if (leds[i].fd == -1) {
			perror("Failed to open /dev/uleds");
			goto exit;
		}

		ret = write(leds[i].fd, &leds[i].uled, sizeof(leds[i].uled));
		if (ret == -1) {
			perror("Failed to write to /dev/uleds");
			goto exit;
		}

		FD_SET(leds[i].fd, &master);
		
		if(leds[i].fd > max_fd) {
			max_fd = leds[i].fd;
		}
	}

	/*
	 * Wait in a select loop for brightness updates from
	 * the kernel
	 */
	while(1) {
		fd_set dup = master;
		ret = select(max_fd+1, &dup, NULL, NULL, NULL);

		if(ret == -1) {
			perror("select() failed");
			goto exit;
		} else {
			/*
			 * For each file descriptor that the kernel has written to,
			 * read the corresponding LED's current brightness value
			 */
			for(i = 0; i < NUM_LEDS; i++) {
				if(FD_ISSET(leds[i].fd, &dup)) {
					ret = read(leds[i].fd, &leds[i].current_brightness, sizeof(leds[i].current_brightness));
					if(ret == -1) {
						perror("read() failed");
						goto exit;
					}
				}
			}
		}

		/*
		 * Create the buffer to send over the uart
		 */
		buf[3] = 0;
		for(i = 0; i < NUM_LEDS; i++) {
			buf[i] = leds[i].current_brightness;
			buf[3] += buf[i];
		}
		buf[3] &= 0xff;


		/*
		 * Open the uart
		 */
		ser_fd = open("/dev/ttyMSM1", O_RDWR);
		if (ser_fd == -1) {
			perror("Failed to open /dev/ttyMSM1");
			close(ser_fd);
			goto exit;
		}

		/*
		 * Write the command and close
		 */
		ret = write(ser_fd, buf, sizeof(buf));
		close(ser_fd);
		if (ret == -1) {
			perror("Failed to write to /dev/ttyMSM1");
			goto exit;
		}
	}

exit:
	for(i = 0; i < NUM_LEDS; i++) {
		close(leds[i].fd);
	}

	return 0;
}
