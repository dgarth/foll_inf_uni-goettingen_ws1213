#!/usr/bin/env python2

import tos

src = "serial@/dev/ttyUSB0:115200"
am = tos.AM(tos.getSource(src))
while True:
    p = am.read()
    print p.data
