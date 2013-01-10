PcSink; Mote-ID = 10 (dezimal)
MSP430 hat 10K RAM und 48K Flash ROM.

PcSink wird auf einem Mote mit externer (5dbi-) Antenne ausgeführt.
Die Mote soll am Fenster des Sensorlabs stehen und mit einem Rechner
per USB verbunden bleiben. Der bei TinyOS mitgelieferte Listener
läuft auf dem Rechner, wobei die Ausgabe geeignet interpretiert wird.

Die PcSink-Mote hat keinen Energiemangel und kann daher auch Berechnungen ausführen,
z.B. mit der Printf-Komponente von TinyOS. Alternativ können Bytefolgen direkt per
AMSend an den PC gesendet werden. Diese werden vom Listener als String ausgegeben
("00" bis "FF", Leerzeichen-getrennt). Die Maximale Nachrichtenlänge ist uint8_t,
also 255 Byte (Limit von AMSend.send()).

Eine "geeignete Interpretation" kann durch ein Programm realisiert werden, das die
Standardausgabe des Listeners verarbeitet und entsprechend aufbereitet.

Die PcSink-Mote empfängt ausschließlich Pakete des Relayknotens (ID = 9) und
sendet auch nur an diese Adresse. Damit sollen Übertragungen aus dem Testfeld
ausgefiltert werden, die eventuell bis zur Sink durchdringen und die gesammelten
Daten inkonsistent machen könnten.

In einem gewissen Zeitintervall (derzeit 5s) fordert die Sink ein ACK vom Relay an,
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

