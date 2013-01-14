Andis Serielles LCD
===================

Ich wollte hier noch mal genau niederschreiben, wie man mein Display ansteuern kann.
Ausserdem lade hier mal die "Firmware" von meinem LCD hoch, falls sich jemand dafuer interessiert.
Ist in C für Atmel Atmega Controller geschrieben und kann mit avr-gcc kompiliert und per avrdude mit
einem AVR-ISP (10 Pin) auf das Board geflasht werden.

### Interface

Das LCD-Board lauscht auf dem seriellen Port auf 8-Bit-Daten im RS232-Modus 8N1. Das ist kompatibel
mit unseren Motes, kann man aber auch ueber einen PC oder sonstwas ansteuern. Bei Sonder- und
Alphanumerischen Zeichen ist es kompatibel zu 7-Bit ASCII.

Desweiteren gibt es ein paar Nicht-Ganz-Standard Steuerzeichen, die es versteht:

### Kommandotabelle

	 HEX		| DEC	| ASCII	| COMMAND
	-----------------------------------------------------------------------------------------------------------
	 0x07		|  7	| BEL	| "Piiiieeep!"
	 0x11		| 17	| DC1	| LED 1 togglen
	 0x12		| 18	| DC2	| LED 2 togglen
	 0x13		| 19	| DC3	| Zeile 1 loeschen und Cursor auf ihre 1. Stelle
	 0x14		| 20	| DC4	| Zeile 2 loeschen und Cursor auf ihre 1. Stelle
	 0x16		| 22	| SYN	| Letzten gedrueckten Knopf anfordern
	 0x20-0x7E	| 32-126| char	| Druckbares Zeichen dieses Wertes an Cursorstelle drucken und Cursor 1 nach rechts

### Knoepfe

Das LCD-Board hat 2 Tastknoepfe, ihr Status kann mit 0x16 angefordert werden, der LCD sendet dann entweder
 *	0x11 (= Knopf 1 zuletzt gedrueckt)
oder
 * 	0x12 (= Knopf 2 zuletzt gedrueckt)

### Auf den Motes

Die Motes schliesst man per Erweiterungsboard mit seriellem Kabel an das LCD-Board an.

Zum Senden und Empfangen ueber den seriellen Port (UART) gibt es das Interface UartStream.

Als Beispiel fuer Initialisierung, Senden/Empfangen & Wiring wuerde ich auf TestRssi verweisen.
Zusammengeklaut habe ich mir das vom Programm "TestEX1000UART" vom Hersteller unserer Motes.

Wichtig fuer uns ist, den UART wieder zu releasen, nachdem man ihn requested hat, da er ueber den selben
Port vom MCU angesteuert wird, wie der Funktransmitter, d.h. solange der UART von uns belegt wird, kann
man den CC2420 nicht ansteuern --> Funkstille. In TestEX1000UART wird das nicht gemacht, was mir ein wenig
Frustration bescherte.

### Known Bugs :P
 
 * Das LCD interpretiert das Nullzeichen momentan noch als vertikalen Balken. Ist nur ein aesthetisches
   Problem, werde ich noch aendern...
