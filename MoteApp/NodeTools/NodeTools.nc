// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

/* NodeTools.nc - Interfacedeklaration. */

interface NodeTools {
	command void setLed(uint8_t led, bool on);
	command void flashLed(uint8_t led, uint8_t times);
//	command void perror(error_t err, const char* failmsg, const char* msg);
	command void debugPrint(const char* str);
	/* Mote-Steuerung per Konsole */
	command void serialInit();
	command void serialShutdown();
	event void onSerialCommand(node_msg_t* cmd);
	command void serialSendOK();
	/* Radio-Adresse (nodeID; CC2420ActiveMessageC != SerialActiveMessageC)
	 * Erstere ist bindend. */
	command uint8_t myAddress();
	/* Queue-Verwaltung */
	command bool queueEmpty();
	command void enqueueMsg(node_msg_t *pmsg);
	command node_msg_t* dequeueMsg();
}
