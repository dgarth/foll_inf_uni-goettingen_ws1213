import java.io.IOException;
import java.io.PrintStream;
import java.util.Scanner;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class MoteConsole implements MessageListener {

	private class MoteCommands {
		public static final short S_OK = 1;
		/* Argument 1 = red, green, blue für LED_RED, LED_GREEN, LED_BLUE */
		public static final short Echo = 2;
		public static final short LedOn = 3;
		public static final short LedOff = 4;
		public static final short LedToggle = 5;
		/* zusätzlich: Argument 2 = Anzahl > 0 */
		public static final short LedBlink = 6;
		/* Argumente in allnodes.h */
		public static final short NewMeasure = 7;
		public static final short StartMeasure = 8;
		public static final short StopMeasure = 9;
		public static final short ClearMeasure = 10;
		public static final short SendReport = 11;
		public static final short UserCmd = 12;
		public static final short DebugOutput = 13;
	}

	private MoteIF moteIF;
	private NodeMsg nodeMsgObj;
	// aktuelles Paket ist unvollständig
	boolean moreData;

	public MoteConsole(MoteIF moteIF) {
		this.moteIF = moteIF;
		this.nodeMsgObj = new NodeMsg();
		this.moteIF.registerListener(this.nodeMsgObj, this);
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
		// command loop
		mif.deregisterListener(mc.nodeMsgObj, mc);
		System.out.println();
		System.exit(0);

		return;
	}

	private void runConsole() {
		boolean bContinue = true;
		String input;
		String[] tokens;
		Scanner sc = new Scanner(System.in);
		NodeMsg msg;
		short cmd;
		Pair<short[], Short> dataObj;

		while (bContinue) {
			msg = new NodeMsg();
			cmd = -1;
			dataObj = null;

			// prompt & read
			//System.out.print("> ");
			input = sc.nextLine();
			tokens = input.split(" ");

			if (tokens.length == 0) {
				continue;
			}

			// help, exit
			if (tokens[0].equals("help")) {
				printHelp();
			} else if (tokens[0].equals("quit") || tokens[0].equals("exit")) {
				bContinue = false;
				continue;
			}

			// LED commands
			if (tokens[0].startsWith("led")) {
				if (tokens[0].equals("ledon") && tokens.length == 3) {
					cmd = MoteCommands.LedOn;
				} else if (tokens[0].equals("ledoff")) {
					cmd = MoteCommands.LedOff;
				} else if (tokens[0].equals("ledtoggle")) {
					cmd = MoteCommands.LedToggle;
				}

				if (tokens[0].equals("ledblink") && tokens.length == 4) {
					cmd = MoteCommands.LedBlink;
					dataObj = getDataForCmd(cmd, tokens[1], tokens[2], tokens[3]);
				} else {
					dataObj = getDataForCmd(cmd, tokens[1], tokens[2]);
				}
			}

			// Echo command
			if (tokens[0].equals("echo")) {
				cmd = MoteCommands.Echo;
				dataObj = new Pair<short[], Short>();
				// Command-Token ignorieren
				dataObj.a = new short[tokens.length - 1];
				for (int i = 1; i < tokens.length; i++) {
					dataObj.a[i-1] = Short.parseShort(tokens[i]);
				}
				dataObj.b = (short) (tokens.length - 1);
			}

			// Measure commands


			// Misc commands

			if (cmd < 0 || dataObj == null) {
				System.out.println("invalid command or argument.");
			} else {
				if (dataObj.b > 25) { System.out.println("warn: data too long"); }
				msg.set_cmd(cmd);
				msg.set_data(dataObj.a);
				msg.set_length(dataObj.b);
				try {
					System.out.println("sending: " + msg.toString());
					moteIF.send(0, msg);
				} catch (IOException ex) {
					System.out.println(ex.toString());
				}
			}

		} // while (bContinue)

		return;
	}

	public void messageReceived(int to, Message msg) {
		NodeMsg nm = (NodeMsg) msg;
		short[] data;
		short dataLength;

		if (nm == null) {
			System.out.println("WARN: NULL-packet received.");
			return;
		}

		data = nm.get_data();
		dataLength = nm.get_length();

		switch (nm.get_cmd()) {
			case MoteCommands.Echo:
				if (data.length > 0) {
					System.out.println(String.format("Echo reply from node %d", data[0]));
				}
				break;

			case MoteCommands.DebugOutput:
				if (!moreData) {
					// neue Meldung
					System.out.print("Debug: ");
				}

				// Daten vom letzten Paket ggf. fortsetzen
				for (int i = 0; i < dataLength; i++) {
					System.out.print((char) data[i]);
				}

				if (!moreData) {
					// alles gesendet - Meldung abschließen
					System.out.println();
				}
				break;

			default:
				System.out.println("Received nodemsg.toString(): " + nm.toString());
		}

		moreData = nm.get_moreData() == 0 ? false : true;
		return;
	}

	private static void usage() {
		System.err.println("usage: MoteConsole -comm <source>");
	}

	private static void printHelp() {
		PrintStream ps = System.out;
		ps.println("Available commands:");
		ps.println("ledon ID (red/green/blue)");
		ps.println("ledoff ID (red/green/blue)");
		ps.println("ledtoggle ID (red/green/blue)");
		ps.println("ledblink ID (red/green/blue) times");
	}

	private static Pair<short[], Short> getDataForCmd(short cmd, String... args) {
		Pair<short[], Short> result = new Pair<short[], Short>();
		short data[] = new short[25];
		short len = 0;

		switch (cmd) {
			case MoteCommands.Echo:
				break;
			case MoteCommands.LedOn:
			case MoteCommands.LedOff:
			case MoteCommands.LedToggle:
				data[0] = Short.parseShort(args[0]); // ID
				data[1] = ledFromString(args[1]); // LED
				len = 2;
				break;
			case MoteCommands.LedBlink:
				data[0] = Short.parseShort(args[0]); // ID
				data[1] = ledFromString(args[1]); // LED
				data[2] = Short.parseShort(args[2]); // # times
				len = 3;
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

		result.a = data;
		result.b = len;
		return result;
	}

	private static short ledFromString(String s) {
		if (s.equals("red")) {
			return 1;
		} else if (s.equals("green")) {
			return 2;
		} else if (s.equals("blue")) {
			return 4;
		}

		return 0;
	}

	private static class Pair<T1, T2> {
		public T1 a;
		public T2 b;
	}
}

