COMPONENT=MoteConsoleAppC
BUILD_EXTRA_DEPS += MoteConsole.class
CLEAN_EXTRA = *.class ConsoleMsg.java

MoteConsole.class: $(wildcard *.java) ConsoleMsg.java
	javac -target 1.4 -source 1.4 *.java

ConsoleMsg.java:
	mig java -target=null -java-classname=ConsoleMsg ConsoleMsg.h console_msg -o ConsoleMsg.java


include $(MAKERULES)

