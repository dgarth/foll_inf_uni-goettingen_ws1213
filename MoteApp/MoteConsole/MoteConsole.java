import java.io.IOException;
import java.io.PrintStream;
import java.util.Scanner;
import java.util.Arrays;
import java.util.concurrent.Semaphore;

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
		public static final short DebugOutput = 12;
	}

	private class Pair<T1, T2> {
		public T1 a;
		public T2 b;
	}

	private boolean debug;
	private MoteIF moteIF;
	private NodeMsg nodeMsgObj;
	// aktuelles Paket ist unvollständig
	boolean moreData;

	// Synchronisation der Ausgabe
	Semaphore outLock;

	public MoteConsole(MoteIF moteIF) {
		this.debug = false;
		this.outLock = new Semaphore(1);
		this.moteIF = moteIF;
		this.nodeMsgObj = new NodeMsg();
		if (moteIF != null) {
			this.moteIF.registerListener(this.nodeMsgObj, this);
		}
	}

	public static void main(String[] args) throws Exception {
		PhoenixSource ps;
		MoteIF mif = null;
		int commParam = Arrays.asList(args).indexOf("-comm");
		int dbgParam = Arrays.asList(args).indexOf("-debug");

		if (commParam > -1) {
			ps = BuildSource.makePhoenix(args[commParam + 1], PrintStreamMessenger.err);
			mif = new MoteIF(ps);
		} else {
			System.out.println("No device specified. Using local mode.");
		}

		MoteConsole mc = new MoteConsole(mif);

		if (dbgParam > -1) {
			mc.debug = true;
			System.out.println("Debug mode enabled.");
		}

		// command loop
		mc.runConsole();

		if (mif != null) {
			mif.deregisterListener(mc.nodeMsgObj, mc);
		}
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

			try {
				outLock.acquire();
			} catch (InterruptedException ex) {}

			// prompt & read
			System.out.print("> ");
			input = sc.nextLine();
			tokens = input.split(" ");

			// tokens.length ist immer > 0
			if (tokens[0].equals("")) {
				outLock.release();
				continue;
			}

			// help, exit
			if (tokens[0].equals("help")) {
				printHelp();
				outLock.release();
				continue;
			} else if (tokens[0].equals("quit") || tokens[0].equals("exit")) {
				bContinue = false;
				outLock.release();
				continue;
			}

			// Command determination
			if (tokens[0].startsWith("led")) {
				// LED commands
				if (tokens[0].equals("ledon")) {
					cmd = MoteCommands.LedOn;
				} else if (tokens[0].equals("ledoff")) {
					cmd = MoteCommands.LedOff;
				} else if (tokens[0].equals("ledtoggle")) {
					cmd = MoteCommands.LedToggle;
				} else if (tokens[0].equals("ledblink")) {
					cmd = MoteCommands.LedBlink;
				}

			} else if (tokens[0].equals("echo")) {
				// Echo command
				cmd = MoteCommands.Echo;

			} else if (tokens[0].equals("newmeasure")) {
				// NewMeasure command
				cmd = MoteCommands.NewMeasure;

			} else if (tokens[0].endsWith("ms")) {
				// Measure control commands
				if (tokens[0].equals("startms")) {
					cmd = MoteCommands.StartMeasure;
				} else if (tokens[0].equals("stopms")) {
					cmd = MoteCommands.StopMeasure;
				} else if (tokens[0].equals("clearms")) {
					cmd = MoteCommands.ClearMeasure;
				}
			}

			// Data determination (shift command away)
			tokens = Arrays.copyOfRange(tokens, 1, tokens.length);
			dataObj = getDataForCmd(cmd, tokens);

			// Transmit request
			if (cmd < 0 || dataObj == null) {
				System.out.println("invalid command or argument.");
				outLock.release();
			} else {
				if (dataObj.b > 25) { System.out.println("warn: data too long"); }
				msg.set_cmd(cmd);
				msg.set_data(dataObj.a);
				msg.set_length(dataObj.b);
				try {
					if (debug) { System.out.println("sending: " + msg.toString()); }
					if (this.moteIF != null) {
						moteIF.send(0, msg);
					}
				} catch (IOException ex) {
					System.out.println(ex.toString());
				}
			}

		} // while (bContinue)

		return;
	}

	private Pair<short[], Short> getDataForCmd(short cmd, String... args) {
		Pair<short[], Short> result = new Pair<short[], Short>();
		short data[] = new short[25];
		short len = 0;

		switch (cmd) {
			case MoteCommands.Echo:
				if (args.length == 0 || args.length > 25) { return null; }
				for (int i = 0; i < args.length; i++) {
					data[i] = Short.parseShort(args[i]);
				}
				len = (short) (args.length);
				break;

			case MoteCommands.LedOn:
			case MoteCommands.LedOff:
			case MoteCommands.LedToggle:
				if (args.length != 2) { return null; }
				data[0] = Short.parseShort(args[0]); // ID
				data[1] = ledFromString(args[1]); // LED
				len = 2;
				break;

			case MoteCommands.LedBlink:
				if (args.length != 3) { return null; }
				data[0] = Short.parseShort(args[0]); // ID
				data[1] = ledFromString(args[1]); // LED
				data[2] = Short.parseShort(args[2]); // # times
				len = 3;
				break;

			case MoteCommands.NewMeasure:
				if (args.length < 4 || args.length > 5) { return null; }
				data[0] = Short.parseShort(args[0]);
				data[1] = Short.parseShort(args[1]);
				storeWORD(Short.parseShort(args[2]), data, 2);
				storeDWORD(Integer.parseInt(args[3]), data, 4);
				len = 8;

				if (args.length == 5) {
					len = (short) storeOptions(args[4], data, len);
				}

				break;

			case MoteCommands.StartMeasure:
			case MoteCommands.StopMeasure:
			case MoteCommands.ClearMeasure:
				if (args.length != 2) { return null; }
				data[0] = Short.parseShort(args[0]); // ID1
				data[1] = Short.parseShort(args[1]); // ID2
				len = 2;
				break;
		}

		result.a = data;
		result.b = len;
		return result;
	}

	private short ledFromString(String s) {
		if (s.equals("red")) {
			return 1;
		} else if (s.equals("green")) {
			return 2;
		} else if (s.equals("blue")) {
			return 4;
		}

		return 0;
	}

	private int storeOptions(String opts, short[] store, int offset) {
		// opts = "opt1=value1,opt2=value2"
		String[] options = opts.split(",");
		int optCount = 0;
		int optCountOffset = 0;
		String[] kvOpt; // keyValue

		if (options.length == 0) {
			return offset;
		} else {
			optCountOffset = offset;
			offset++;
		}

		for (int i = 0; i < options.length; i++) {
			// evaluate key/value pair
			kvOpt = options[i].split("=");

			if (kvOpt[0].equals("mcount")) {
				// makeDWORD(hi, lo), lo = option 1 (allnodes.h)
				storeDWORD(makeDWORD(Short.parseShort(kvOpt[1]), (short)1), store, offset);
				if (debug) { System.out.println("mcount option at " + offset + ", value = " + kvOpt[1]); }
				offset += 4;
				optCount++;
			} else if (kvOpt[0].equals("mnode")) {
				// makeDWORD(hi, lo), lo = option 2 (allnodes.h)
				storeDWORD(makeDWORD(Short.parseShort(kvOpt[1]), (short)2), store, offset);
				if (debug) { System.out.println("mnode option at " + offset + ", value = " + kvOpt[1]); }
				offset += 4;
				optCount++;
			}
		}

		store[optCountOffset] = (short) optCount;
		if (debug) {
			System.out.println(String.format("option count %d at %d", optCount, optCountOffset));
		}

		return offset;
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
			case MoteCommands.S_OK:
				System.out.println("OK");
				outLock.release();
				break;

			case MoteCommands.Echo:
				if (data.length > 0) {
					System.out.println(String.format("Echo reply from node %d", data[0]));
				}
				break;

			case MoteCommands.SendReport:
				String fmt = String.format("Measure set %d from [%d --> %d] at %d, RSSI = %d",
				getWORD(data, 1), data[8], data[0], getDWORD(data, 3), data[7]);
				System.out.println(fmt);
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
				System.out.println("WARN: Received undefined message.");
				if (debug) { System.out.println("Undefined: " + nm.toString()); }
				break;
		}

		moreData = nm.get_moreData() == 0 ? false : true;
		return;
	}

	private void printHelp() {
		PrintStream ps = System.out;
		ps.println("Available commands:");
		ps.println("echo ID [further IDs]");
		ps.println("ledon ID red/green/blue");
		ps.println("ledoff ID red/green/blue");
		ps.println("ledtoggle ID red/green/blue");
		ps.println("ledblink ID red/green/blue times");
		ps.println("newmeasure ID1 ID2 measure_set stime [opt1=value1,opt2=value2,...]");
		ps.println("newmeasure options:");
		ps.println("   mcount (measurement count, uint16)");
		ps.println("   mnode (monitor node ID, uint8)");
		ps.println("startms ID1 ID2");
		ps.println("stopms ID1 ID2");
		ps.println("clearms ID1 ID2");
	}

	private short loword(int dword) {
		return (short) dword;
	}

	private short hiword(int dword) {
		return (short) (dword >> 16);
	}

	private void storeWORD(short word, short[] store, int index) {
		store[index + 1] = (short) (word >> 8);
		store[index] = (short) (word & 0xFF);
	}

	private void storeDWORD(int dword, short[] store, int index) {
		storeWORD(loword(dword), store, index);
		storeWORD(hiword(dword), store, index + 2);
	}

	private int makeDWORD(short hiword, short loword) {
		return (hiword << 16) | loword;
	}

	private short getWORD(short[] x, int index) {
		if (x.length < 2) {
			return 0;
		} else {
			return (short) ((x[index + 1] << 8) | x[index]);
		}
	}

	private int getDWORD(short[] x, int index) {
		if (x.length < 4) {
			return 0;
		} else {
			return (x[index + 3] << 24) | (x[index + 2] << 16) | (x[index + 1] << 8) | x[index];
		}
	}
}

