all: RssiMsg.py

RssiMsg.py: ../Rssi.h
	mig python -target=null -python-classname=RssiMsg $< RssiMsg -o $@

clean:
	@rm -f RssiMsg.py
	@rm -f *.pyc

.PHONY: clean
