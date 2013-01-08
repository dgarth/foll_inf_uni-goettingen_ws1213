#!/usr/bin/env python2

# edit this if necessary
src = 'serial@/dev/ttyUSB0:115200'

import sys
import os
import struct

try:
    TOS_ROOT = os.environ['TOSROOT']
    TOS_PATH = os.path.join(TOS_ROOT, 'support/sdk/python')
except KeyError:
    TOS_PATH = '/opt/tinyos-2.1.2/support/sdk/python'

sys.path.append(TOS_PATH)

try:
    import tos
except ImportError:
    print 'please set TOSROOT correctly'
    sys.exit(1)

from RssiMsg import RssiMsg

RSSI_OFFSET = -45


def get_val(data, name, fmt):
    m = RssiMsg()
    start = getattr(m, 'offset_' + name)()
    end = start + getattr(m, 'size_' + name)()
    s = str(bytearray(data[start:end]))
    return struct.unpack(fmt, s)[0]


def get_source(data):
    return get_val(data, 'source', '>H')


def get_destination(data):
    return get_val(data, 'destination', '>H')


def get_counter(data):
    return get_val(data, 'counter', '>H')


def get_rssi(data):
    return get_val(data, 'rssi', '>h') - RSSI_OFFSET


am = tos.AM(tos.getSource(src))

while True:
    p = am.read()
    data = p.data
    s = get_source(data)
    d = get_destination(data)
    c = get_counter(data)
    r = get_rssi(data)

    print '%d -> %d, counter: %d, rssi: %d' % (s, d, c, r)
