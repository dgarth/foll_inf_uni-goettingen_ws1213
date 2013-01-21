#include "allnodes.h"

interface LcdMenu {
	/*TODO: "Menue" (haha) zur Benutzereingabe*/
	command error_t getUserCmd(node_msg_t *cmd);
	/*DONE: Report aus node_msg_t an LCD*/
	command error_t showReport(const node_msg_t *report);
	
	
	/*wenn die Nachricht vom Menue generiert wurde*/
	event void cmd_msg_ready(node_msg_t *cmd);
}