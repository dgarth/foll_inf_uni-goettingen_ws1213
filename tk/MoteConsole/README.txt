MoteConsole: Ermöglicht die Steuerung von Motes über
eine Java-Konsolenanwendung (Terminal).

Diese Anwendung besteht aus zwei Teilen:
 - PC-Teil (MoteConsole.java)
 - Mote-Teil (MoteConsoleC.nc)

Der Anwendung liegt eine allgemeine Datenstruktur zugrunde
(definiert in allnodes.h). Diese ist vom Typ nx_struct,
besteht also aus "externen" Typen (laut TinyOS-Doku).

Dieser externe Typ wird vom Tool "mig" in eine Java-Klasse
konvertiert, deren Instanzen dann von einer Java-Anwendung
einfach in das serielle Interface geschrieben werden können
(natürlich über eine passende Serialisierung, die aber von
der Klasse MoteIF übernommen wird). MoteIF wird instanziert
und dient zum Senden und Empfangen von Nachrichtenobjekten
über die serielle Schnittstelle.

MoteIF benötigt die Klasse PhoenixSource, die mit dem
gewünschten seriellen Device (serial@/dev/ttyUSBXXX:telosb)
instanziert wird und keiner weiteren Konfiguration bedarf.

Der Aufruf zum Generieren der Java-Klasse aus allnodes.h
(das Nachrichtenobjekt) findet sich im Makefile, die
Java-Applikation selbst wird wie üblich kompiliert.

---
Der Mote-Teil verwendet die Datenstrutur in allnodes.h
direkt (#include) und sendet und empfängt Daten wie üblich
per AMSend und Receive. Die Wirings binden dabei nicht an
CC2420ActiveMessageC, sondern an SerialActiveMessageC.
Ansonsten ist die Kommunikation identisch zur
RF-Kommunikation.

