import java.io.IOException;
import java.io.PrintStream;
import java.util.Scanner;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class MoteConsole implements MessageListener {

	private class MoteCommands {
		/* Argument 1 = 1, 2, 3 für LED_RED, LED_GREEN, LED_BLUE */
		public static final short LedOn = 1;
		public static final short LedOff = 2;
		public static final short LedToggle = 3;
		/* zusätzlich: Argument 2 = Anzahl > 0 */
		public static final short LedBlink = 4;
	}

	private MoteIF moteIF;

	public MoteConsole(MoteIF moteIF) {
		this.moteIF = moteIF;
		this.moteIF.registerListener(new ConsoleMsg(), this);
	}

	public static void main(String[] args) throws Exception {

		if (args.length != 2 || !args[0].equals("-comm")) {
			usage();
			System.exit(1);
		}
 
		PhoenixSource ps;
		ps = BuildSource.makePhoenix(args[1], PrintStreamMessenger.err);

		MoteIF mif = new MoteIF(ps);
		MoteConsole mc = new MoteConsole(mif);
		mc.runConsole();
	}

	private void runConsole() {
		boolean bContinue = true;
		String input;
		String[] tokens;
		Scanner sc = new Scanner(System.in);
		ConsoleMsg msg;

		while (bContinue) {
			msg = new ConsoleMsg();

			// prompt & read
			System.out.print("> ");
			input = sc.nextLine();
			tokens = input.split(" ");

			if (tokens.length == 0) {
				continue;
			}

			// LED commands
			if (tokens[0].startsWith("led")) {
				

			if (tokens[0].equals("ledon")) {
				msg.set_cmd(MoteCommands.LedOn);
				msg.set_data(new short[] {Short.parseShort(tokens[1])});

			} else if (tokens[0].equals("ledoff")) {
				msg.set_cmd(MoteCommands.LedOff);
				msg.set_data(new short[] {Short.parseShort(tokens[1])});

			} else if (tokens[0].equals("ledtoggle")) {
				msg.set_cmd(MoteCommands.LedOn);
				msg.set_data(new short[] {Short.parseShort(tokens[1])});

			} else if (tokens[0].equals("ledblink")) {
				msg.set_cmd(MoteCommands.LedBlink);
				msg.set_data(new short[] {Short.parseShort(tokens[1])});
			}

			try {
				System.out.println("sending: " + msg.toString());
				moteIF.send(0, msg);
				System.out.println("sent");
			} catch (IOException ex) {
				System.out.println(ex.toString());
			}
		}

	}

	public void messageReceived(int to, Message msg) {
		ConsoleMsg cm = (ConsoleMsg) msg;
		System.out.println("Received cm.toString(): " + cm.toString());
	}

	private static void usage() {
		System.err.println("usage: MoteConsole -comm <source>");
	}

}

