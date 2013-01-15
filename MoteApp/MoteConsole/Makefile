default: $(wildcard *.java) NodeMsg.java
	javac *.java

NodeMsg.java:
	mig java -target=null -java-classname=NodeMsg allnodes.h node_msg -o NodeMsg.java

clean:
	rm -f NodeMsg.java *.class

