# for collection
CFLAGS += -I$(TOSDIR)/lib/net/ -I$(TOSDIR)/lib/net/ctp  -I$(TOSDIR)/lib/net/4bitle

# for dissemination
CFLAGS += -I$(TOSDIR)/lib/net/drip

# hide some warnings
CFLAGS += -Wno-unused-but-set-variable -Wno-missing-braces
