/* NodeToolsP.nc - Implementierung des Interfaces NodeTools. */

#include <printf.h>

module NodeToolsP {
	provides interface NodeTools;
	uses interface Leds;
	uses interface Timer<TMilli> as TBlinkLed0;
	uses interface Timer<TMilli> as TBlinkLed1;
	uses interface Timer<TMilli> as TBlinkLed2;
}

implementation {
	uint16_t blinkCount[3];
	uint8_t blinkLed;

	/* Schaltet LEDs an oder aus. */
	command void NodeTools.setLed(uint8_t led, bool on) {
		uint8_t state = call Leds.get();

		if (on) {
			call Leds.set(state | led);
		} else {
			call Leds.set(state & ~led);
		}

	}

	/* Lässt die angegebene LED times mal blinken. */
	command void NodeTools.flashLed(uint8_t led, uint8_t times) {

		switch (led) {
			case LED_RED:
				blinkCount[0] = 2 * times;
				call TBlinkLed0.startPeriodic(100);
				break;
			case LED_GREEN:
				blinkCount[1] = 2 * times;
				call TBlinkLed1.startPeriodic(100);
				break;
			case LED_BLUE:
				blinkCount[2] = 2 * times;
				call TBlinkLed2.startPeriodic(100);
				break;
		}
	}

	/* TBlink-Handler */
	event void TBlinkLed0.fired() {
		call NodeTools.setLed(LED_RED, blinkCount[0] % 2 == 0);
		blinkCount[0] -= 1;
		if (blinkCount[0] == 0) {
			call TBlinkLed0.stop();
		}
	}

	event void TBlinkLed1.fired() {
		call NodeTools.setLed(LED_GREEN, blinkCount[1] % 2 == 0);
		blinkCount[1] -= 1;
		if (blinkCount[1] == 0) {
			call TBlinkLed1.stop();
		}
	}

	event void TBlinkLed2.fired() {
		call NodeTools.setLed(LED_BLUE, blinkCount[2] % 2 == 0);
		blinkCount[2] -= 1;
		if (blinkCount[2] == 0) {
			call TBlinkLed2.stop();
		}
	}


	/* Gibt die String-Darstellung des übergebenen Fehlers mit printf() aus.
	 * Wenn err == SUCCESS, wird nur msg ausgegeben, sonst wird failmsg an den
	 * ausgegebenen Fehler angehängt. */
	command void NodeTools.perror(error_t err, const char* failmsg, const char* msg) {
		/* TODO Gibt es sowas wie strerror? */
		char buffer[50];

		switch (err) {
			case EBUSY:
				strcpy(buffer, "EBUSY");
				break;
			case FAIL:
				strcpy(buffer, "FAIL");
				break;
		}
		if (err == SUCCESS) {
			printf("%s", msg);
		} else {
			printf("Error %s in %s.\n", buffer, failmsg);
		}
		printfflush();
	}

}

