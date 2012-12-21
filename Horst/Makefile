BUILD_EXTRA_DEPS = RssiMsg.py
CLEAN_EXTRA = RssiMsg.py

RssiMsg.py: SendRssi.h
	mig python -target=$(PLATFORM) -python-classname=RssiMsg $< RssiMsg -o $@


COMPONENT=HorstAppC
include $(MAKERULES)

