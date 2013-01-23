//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

configuration DokuAppC {
/* Konfigurationsteil - Hier werden alle Interfaces deklariert, die in der aktuellen Datei verwendet oder von ihr implementiert werden. In diesem Modul gibt es nur Wirings und keinen Code, also ist diese Sektion leer. */
}

implementation {
	/* Deklaration von externen und eigenen Komponenten (ggf. Erzeugung von Instanzen).
	 * "Eigene Komponenten" sind die, aus denen die App aufgebaut ist. */

	/* externe Komponenten; "as" gibt verschiedenen Instanzen einer Komponente Namen, um sie zu unterscheiden. */
	components MainC, LedsC;
	/* Das Interface heißt Timer<TMilli> und wird in TimerMilliC implementiert. */
	components new TimerMilliC() as Timer0; 

	/* eigene Komponenten */
	components DokuC;

	/* Wirings; Grundsätzliche Form:
	 * Handlermodul.Variable -> Providermodul.Interface
	 * Ist das Interface eindeutig (nur eine Instanz), kann es weggelassen werden.
	 * Das bedeutet, dass Variablennamen standardmäßig dem Interface- bzw. Komponentennamen entsprechen.
	 * Wirings werden zum Behandeln von Events (hier Timer) und zum Aufrufen von Commands (hier Leds) benötigt. */

	/* Variable Horst in DokuC; kein Handler, gebunden an LedsC.Leds (Leds definiert die LED-Kontrolle, LedsC implementiert sie. */
	DokuC.Horst -> LedsC;
	/* Variable MyTimer in DokuC; Handler = "event void MyTimer.fired()", gebunden an Timer0.fired(). */
	DokuC.MyTimer -> Timer0.Timer;
	/* Variable Boot (implizit) in DokuC; Handler = "event void Boot.booted()", gebunden an Boot.booted() (implizit). */
	DokuC.Boot -> MainC;
}

