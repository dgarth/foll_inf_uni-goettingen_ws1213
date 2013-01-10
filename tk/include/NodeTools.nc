/* NodeTools.nc - Interfacedeklaration. */

interface NodeTools {
	command void setLed(uint8_t led, bool on);
	command void flashLed(uint8_t led, uint8_t times);
	command void perror(error_t err, const char* failmsg, const char* msg);
}

