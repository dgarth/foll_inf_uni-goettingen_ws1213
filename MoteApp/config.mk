# "global" make configuration for networking, warnings, etc.
# usage: include path/to/config.mk

CFLAGS += -Wnesc-all

# for collection
CFLAGS += -I$(TOSDIR)/lib/net -I$(TOSDIR)/lib/net/ctp  -I$(TOSDIR)/lib/net/4bitle

# for dissemination
CFLAGS += -I$(TOSDIR)/lib/net/drip

# hide warnings thrown by TOS networking code
CFLAGS += -Wno-unused-but-set-variable -Wno-missing-braces
