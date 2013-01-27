// vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

/* NodeComm.nc - Interfacedeklaration. */

interface NodeComm {
	command void init();
	// Kommando per Dissemination empfangen
	event void dissReceive(const node_msg_t* cmd);
	// Report per Collection empfangen
	event void collReceive(node_msg_t* msg);
	// Kommando per Dissemination weiterleiten
	command void dissSend(node_msg_t* cmd);
	// Report per Collection weiterleiten
	command void collSend(node_msg_t* msg);
}
