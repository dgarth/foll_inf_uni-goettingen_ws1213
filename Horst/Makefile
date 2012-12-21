BUILD_EXTRA_DEPS = SerialMsg.py
CLEAN_EXTRA = SerialMsg.py

SerialMsg.py: Horst.h
	mig python -target=$(PLATFORM) -python-classname=SerialMsg $< SerialMsg -o $@


COMPONENT=HorstAppC
include $(MAKERULES)

