/* DokuC: Konfiguration und Implementierung der App-eigenen Komponente DokuC. Diese wird in DokuAppC an die benutzten Interfaces gebunden. */

/* Konfigurationsteil - Deklaration aller verwendeten Interfaces. Das Attribut @safe() kann den Speicher java-like überwachen (aber kein GC). Mehr dazu im TinyOS Wiki. */
module DokuC /*@safe()*/ {
	uses interface Timer<TMilli> as MyTimer;
	uses interface Boot; /* implizit "as Boot" */
	uses interface Leds as Horst;
}

/* Globale Variablen, Eventhandler und die Implementierung von Interfaces, die oben als "provides" deklariert sind. */
implementation {
	uint8_t state = 0;

	event void Boot.booted() {
		call MyTimer.startPeriodic(1000);
	}

	event void MyTimer.fired() {
		call Horst.led0Toggle();
	}

}
