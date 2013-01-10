TestRssi ist abgewandelt von apps/tests/cc2420/TestAcks/. Wenn man es auf zwei Motes
gleicher ID aufspielt, fangen diese an, sich gegenseitig im Dauerlauf ACK-Requests und
ACK-Pakete zu senden. Von diesen Paketen wird kontinuierlich der RSSI-Wert ausgelesen und
auf dem seriellen Port ausgegeben (sofern das Expansion Board aufgesteckt ist) und man
kann ihn dann auf meinem wunderschönen Eigenbau-Display lesen, wenn man will ;)

Der Code ist aufgrund seiner zusammenkopierten Natur recht hässlich, aber ich mute ihn euch
jetzt trotzdem mal so zu :P

Schöne Grüße
Andi