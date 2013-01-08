#!/usr/bin/env python2

import sys
sys.path.append("/opt/tinyos-2.1.2/support/sdk/python")
import struct

import tos
from RssiMsg import RssiMsg

RSSI_OFFSET = -45

def get_val(data, name, fmt):
    m = RssiMsg()
    off = getattr(m, "offset_" + name)()
    size = getattr(m, "size_" + name)()
    s = str(bytearray(data[off:off+size]))
    return struct.unpack(fmt, s)[0]

def get_source(data):
    return get_val(data, "source", ">H")

def get_destination(data):
    return get_val(data, "destination", ">H")

def get_counter(data):
    return get_val(data, "counter", ">H")

def get_rssi(data):
    return get_val(data, "rssi", ">h") - RSSI_OFFSET

src = "serial@/dev/ttyUSB0:115200"
am = tos.AM(tos.getSource(src))
while True:
    p = am.read()
    data = p.data
    s = get_source(data)
    d = get_destination(data)
    c = get_counter(data)
    r = get_rssi(data)

    print "%d -> %d, counter: %d, rssi: %d" % (s, d, c, r)
