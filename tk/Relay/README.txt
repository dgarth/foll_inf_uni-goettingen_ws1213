Relay; Mote-ID = 9 (dezimal)
MSP430 hat 10K RAM und 48K Flash ROM.

Die Relay-App wird auf einem Mote mit externer (5dbi-) Antenne ausgeführt.
Die Mote soll vor der Witterung geschützt auf der Wiese liegen und Daten an
die Sink am Fenster des Sensorlabs weiterleiten.

Die Relay-Mote empfängt Pakete von allen IDs und sendet alles, was von der Sink
kommt, als Broadcast an die messenden Nodes. Alles, was von diesen kommt, wird
per Unicast an die Sink gesendet.

In einem gewissen Zeitintervall (derzeit 5s) fordert das Relay ein ACK vom Sink an,
um dann mit der blauen LED zu signalisieren, ob noch Kontakt besteht (An = letzte
ACK-Anforderung wurde beantwortet, Aus = nicht beantwortet).

Die grüne LED blinkt einmal, wenn ein Datenpaket empfangen wurde (in Receive.receive(...)).

Bisher sind folgende Nachrichtentypen definiert (siehe allnodes.h):
 - Ping
 - neue Messreihe
 - Messwert
 - Ack / Reply

Beim Kompilieren kommt eine Warnung "Low power communication disabled".
Das ist eher ein Hinweis als eine Warnung und bedeutet, dass Energiesparen möglich,
aber nicht aktiviert ist.

