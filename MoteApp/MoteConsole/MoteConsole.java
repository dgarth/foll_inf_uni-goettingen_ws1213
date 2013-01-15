import java.io.IOException;
import java.io.PrintStream;
import java.util.Scanner;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class MoteConsole implements MessageListener {

	private class MoteCommands {
		/* Argument 1 = 1, 2, 3 für LED_RED, LED_GREEN, LED_BLUE */
		public static final short Echo = 1;
		public static final short LedOn = 2;
		public static final short LedOff = 3;
		public static final short LedToggle = 4;
		/* zusätzlich: Argument 2 = Anzahl > 0 */
		public static final short LedBlink = 5;
		/* Argumente in allnodes.h */
		public static final short NewMeasure = 6;
		public static final short StartMeasure = 7;
		public static final short StopMeasure = 8;
		public static final short ClearMeasure = 9;
		public static final short SendReport = 10;
		public static final short UserCmd = 11;
	}

	private MoteIF moteIF;

	public MoteConsole(MoteIF moteIF) {
		this.moteIF = moteIF;
		this.moteIF.registerListener(new NodeMsg(), this);
	}

	public static void main(String[] args) throws Exception {

		if (!(args.length == 2 && args[0].equals("-comm"))) {
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
		NodeMsg msg;
		short cmd;
		short[] data;

		while (bContinue) {
			msg = new NodeMsg();
			cmd = -1;
			data = null;

			// prompt & read
			System.out.print("> ");
			input = sc.nextLine();
			tokens = input.split(" ");

			if (tokens.length == 0) {
				continue;
			}

			if (tokens[0].equals("help")) {
				printHelp();
			}

			// LED commands
			if (tokens[0].startsWith("led")) {
				if (tokens[0].equals("ledon") && tokens.length == 3) {
					cmd = MoteCommands.LedOn;
				} else if (tokens[0].equals("ledoff")) {
					cmd = MoteCommands.LedOff;
				} else if (tokens[0].equals("ledtoggle")) {
					cmd = MoteCommands.LedBlink;
				}

				if (tokens[0].equals("ledblink") && tokens.length == 4) {
					cmd = MoteCommands.LedBlink;
					data = getDataForCmd(cmd, tokens[1], tokens[2], tokens[3]);
				} else {
					data = getDataForCmd(cmd, tokens[1], tokens[2]);
				}
			}

			if (cmd < 0 || data == null) {
				System.out.println("invalid command or argument.");
			} else {
				try {
					System.out.println("sending: " + msg.toString());
					moteIF.send(0, msg);
					System.out.println("sent");
				} catch (IOException ex) {
					System.out.println(ex.toString());
				}
			}

		} // while (bContinue)

	}

	public void messageReceived(int to, Message msg) {
		NodeMsg nm = (NodeMsg) msg;
		System.out.println("Received nodemsg.toString(): " + nm.toString());
	}

	private static void usage() {
		System.err.println("usage: MoteConsole -comm <source>");
	}

	private static void printHelp() {
		PrintStream ps = System.out;
		ps.println("Available commands:");
		ps.println("ledon ID LED");
		ps.println("ledoff ID LED");
		ps.println("ledtoggle ID LED");
		ps.println("ledblink ID LED times");
	}

	private static short[] getDataForCmd(short cmd, String... args) {
		short data[] = new short[25];

		switch (cmd) {
			case MoteCommands.Echo:
				break;
			case MoteCommands.LedOn:
			case MoteCommands.LedOff:
			case MoteCommands.LedToggle:
				data[0] = Short.parseShort(args[0]); // ID
				data[1] = Short.parseShort(args[1]); // LED
				break;
			case MoteCommands.LedBlink:
				data[0] = Short.parseShort(args[0]); // ID
				data[1] = Short.parseShort(args[1]); // LED
				data[2] = Short.parseShort(args[2]); // # times
				break;
			case MoteCommands.NewMeasure:
				break;
			case MoteCommands.StartMeasure:
				break;
			case MoteCommands.StopMeasure:
				break;
			case MoteCommands.ClearMeasure:
				break;
			case MoteCommands.SendReport:
				break;
			case MoteCommands.UserCmd:
				break;
		}

		return data;
	}

}

