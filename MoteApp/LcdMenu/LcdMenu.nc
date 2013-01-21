#include "allnodes.h"

interface LcdMenu {
	/*"Menue" (haha) zur Benutzereingabe
	(VORSICHT: Die Eingabe ist erst fertig, wenn untenstehendes
	event gefeuert ist (UART-Kommunikation ist asynchron...)*/
	command void getUserCmd(node_msg_t *cmd);
	/*Report aus node_msg_t an LCD*/
	command error_t showReport(const node_msg_t *report);
	
	/*wenn die Nachricht vom Menue generiert wurde kriegt ihr den event*/
	event void cmd_msg_ready(node_msg_t *cmd);
}