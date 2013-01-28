default: MoteConsole.java

COMMANDS =          \
	S_OK            \
	CMD_ECHO        \
	CMD_LEDON       \
	CMD_LEDOFF      \
	CMD_LEDTOGGLE   \
	CMD_LEDBLINK    \
	CMD_NEWMS       \
	CMD_STARTMS     \
	CMD_STOPMS      \
	CMD_CLEARMS     \
	CMD_REPORT      \
	DEBUG_OUTPUT    \

MoteConsole.java: MoteCommands.java NodeMsg.java
	javac $@

MoteCommands.java: ../allnodes.h
	ncg java -target=null -java-classname=$(basename $@ .java) $< $(COMMANDS) -o $@

NodeMsg.java: ../allnodes.h
	mig java -target=null -java-classname=$(basename $@ .java) $< node_msg -o $@

clean:
	rm -f NodeMsg.java MoteCommands.java *.class

