import java.io.IOException;
import java.io.PrintStream;
import java.util.Scanner;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class TestSerial implements MessageListener {

  private MoteIF moteIF;
  
  public TestSerial(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new TestSerialMsg(), this);
  }

  public void sendPackets() {
    TestSerialMsg payload = new TestSerialMsg();
	Scanner sc = new Scanner(System.in);    
	PrintStream o = System.out;

	short cmd;

    try {
      while (true) {

	o.print("(cmd)> ");
	cmd = (short) sc.nextInt();

	payload.set_cmd(cmd);

	System.out.println("Sending command " + cmd);
	moteIF.send(0, payload);
      }
    }
    catch (IOException exception) {
      System.err.println("Exception thrown when sending packets. Exiting.");
      System.err.println(exception);
    }
  }

  public void messageReceived(int to, Message message) {
    TestSerialMsg msg = (TestSerialMsg)message;
	System.out.println("Received msg.toString(): " + msg.toString());
  }
  
  private static void usage() {
    System.err.println("usage: TestSerial [-comm <source>]");
  }
  
  public static void main(String[] args) throws Exception {
    String source = null;
    if (args.length == 2) {
      if (!args[0].equals("-comm")) {
	usage();
	System.exit(1);
      }
      source = args[1];
    }
    else if (args.length != 0) {
      usage();
      System.exit(1);
    }
    
    PhoenixSource phoenix;
    
    if (source == null) {
      phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
    }
    else {
      phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
    }

    MoteIF mif = new MoteIF(phoenix);
    TestSerial serial = new TestSerial(mif);
    serial.sendPackets();
  }


}
