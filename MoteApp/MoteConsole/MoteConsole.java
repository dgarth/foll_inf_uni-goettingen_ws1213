import java.io.*;
import java.util.*;
import java.util.concurrent.Semaphore;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class MoteConsole implements MessageListener {

	private class Pair<T1, T2> {
		public T1 a;
		public T2 b;
	}

	private final int MAX_DATA = 10;
	private boolean debug;
	private boolean localCmd;
	private MoteIF moteIF; // serielles Interface
	private NodeMsg nodeMsgObj; // gesendetes/empfangenes Paket
	boolean moreData; // aktuelles Paket ist unvollständig
	Semaphore outLock; // Synchronisation der Ausgabe
	private PrintStream logFile;
	private String logPath;

	public MoteConsole(MoteIF moteIF) {
		this.debug = false;
		this.localCmd = false;
		this.moteIF = moteIF;
		this.nodeMsgObj = new NodeMsg();
		this.moreData = false;
		this.outLock = new Semaphore(1);
		this.logFile = null;
		this.logPath = null;

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

			// Local command determination
			if (tokens[0].equals("help")) {
				printHelp();
				localCmd = true;
			} else if (tokens[0].equals("quit") || tokens[0].equals("exit")) {
				bContinue = false;
				localCmd = true;
			} else if (tokens[0].equals("setlog")) {
				setLogfile(tokens.length == 2 ? tokens[1] : null);
				localCmd = true;
			} else if (tokens[0].equals("printlog")) {
				printLogfile(tokens.length == 2 ? tokens[1] : null);
				localCmd = true;
			}

			if (localCmd) {
				localCmd = false;
				outLock.release();
				continue;
			}

			// Mote command determination
			if (tokens[0].startsWith("led")) {
				// LED commands
				if (tokens[0].equals("ledon")) {
					cmd = MoteCommands.CMD_LEDON;
				} else if (tokens[0].equals("ledoff")) {
					cmd = MoteCommands.CMD_LEDOFF;
				} else if (tokens[0].equals("ledtoggle")) {
					cmd = MoteCommands.CMD_LEDTOGGLE;
				} else if (tokens[0].equals("ledblink")) {
					cmd = MoteCommands.CMD_LEDBLINK;
				}

			} else if (tokens[0].equals("echo")) {
				// Echo command
				cmd = MoteCommands.CMD_ECHO;

			} else if (tokens[0].equals("newms")) {
				// NewMeasure command
				cmd = MoteCommands.CMD_NEWMS;

			} else if (tokens[0].endsWith("ms")) {
				// Measure control commands
				if (tokens[0].equals("startms")) {
					cmd = MoteCommands.CMD_STARTMS;
				} else if (tokens[0].equals("stopms")) {
					cmd = MoteCommands.CMD_STOPMS;
				} else if (tokens[0].equals("clearms")) {
					cmd = MoteCommands.CMD_CLEARMS;
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
				if (dataObj.b > MAX_DATA) { System.out.println("warn: data too long"); }
				msg.set_cmd(cmd);
				msg.set_data(dataObj.a);
				msg.set_length(dataObj.b);
				try {
					if (debug) { System.out.println("sending: " + msg.toString()); }
					if (this.moteIF != null) {
						moteIF.send(0, msg);
					} else {
						outLock.release();
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
		short data[] = new short[MAX_DATA];
		short len = 0;

		switch (cmd) {
			case MoteCommands.CMD_ECHO:
				if (args.length == 0 || args.length > MAX_DATA) { return null; }
				for (int i = 0; i < args.length; i++) {
					data[i] = Short.parseShort(args[i]);
				}
				len = (short) (args.length);
				break;

			case MoteCommands.CMD_LEDON:
			case MoteCommands.CMD_LEDOFF:
			case MoteCommands.CMD_LEDTOGGLE:
				if (args.length != 2) { return null; }
				data[0] = Short.parseShort(args[0]); // ID
				data[1] = ledFromString(args[1]); // LED
				len = 2;
				break;

			case MoteCommands.CMD_LEDBLINK:
				if (args.length != 3) { return null; }
				data[0] = Short.parseShort(args[0]); // ID
				data[1] = ledFromString(args[1]); // LED
				data[2] = Short.parseShort(args[2]); // # times
				len = 3;
				break;

			case MoteCommands.CMD_NEWMS:
				if (args.length != 4) { return null; }
				data[0] = Short.parseShort(args[0]);
				data[1] = Short.parseShort(args[1]);
				storeWORD(Short.parseShort(args[2]), data, 2);
				storeWORD(Short.parseShort(args[3]), data, 4);
				len = 6;
				break;

			case MoteCommands.CMD_STARTMS:
			case MoteCommands.CMD_STOPMS:
			case MoteCommands.CMD_CLEARMS:
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

	private void setLogfile(String path) {

		if (path == null) {
			System.out.println("No argument specified.");
			return;
		}

		if (path.equals("none")) {
			if (logPath == null) {
				System.out.println("Not currently logging");
			} else {
				System.out.println("closing log file " + logPath);
				logFile.flush();
				logFile.close();
				logFile = null;
				logPath = null;
			}
		} else {
			if (logPath != null) {
				System.out.println("Already logging to " + logPath);
			} else {
				logPath = path;
				try {
					// open & append or create, autoflush
					logFile = new PrintStream(new FileOutputStream(logPath, true), true);
					System.out.println("File '" + logPath + "' opened.");
				} catch (FileNotFoundException ex) {
					System.out.println("Error: Could not open file.");
					logFile = null;
					logPath = null;
				}
			}
		}
	}

	private void printLogfile(String param) {
		int lines = 0;
		Process p = null;
		BufferedReader br = null;
		String line = null;
		String cmd = null;

		try {
			lines = Integer.parseInt(param);
		} catch (NumberFormatException ex) { /* print all */ }

		if (logPath == null) {
			System.out.println("Not currently logging");
			return;
		}

		if (lines > 0) {
			// call tail -lines logPath
			cmd = "/usr/bin/tail -" + lines + " " + logPath;
		} else {
			// call cat logPath
			cmd = "/bin/cat " + logPath;
		}

		try {
			p = Runtime.getRuntime().exec(cmd);
			p.waitFor();
			br = new BufferedReader(new InputStreamReader(p.getInputStream()));
			line = br.readLine();
			while (line != null) {
				System.out.println(line);
				line = br.readLine();
			}
		} catch(IOException e1) {
		} catch(InterruptedException e2) {}
	}

	/*private int storeOptions(String opts, short[] store, int offset) {
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
	}*/

	public void messageReceived(int to, Message msg) {
		NodeMsg nm = (NodeMsg) msg;
		short[] data;
		short dataLength;

		if (nm == null) {
			logMsgln("WARN: NULL-packet received.");
			return;
		}

		data = nm.get_data();
		dataLength = nm.get_length();

		switch (nm.get_cmd()) {
			case MoteCommands.S_OK:
				System.out.println("OK");
				outLock.release();
				break;

			case MoteCommands.CMD_ECHO:
				if (data.length > 0) {
					logMsgln(String.format("Echo reply from node %d", data[0]));
				}
				break;

			case MoteCommands.CMD_REPORT:
				String fmt = String.format("Measure #%d from set %d [%d --> %d], RSSI = %d",
				getWORD(data, 4), getWORD(data, 4), data[1], data[0], (byte)data[6]);
				logMsgln(fmt);
				break;

			case MoteCommands.DEBUG_OUTPUT:
				if (!moreData) {
					// neue Meldung
					logMsg("Debug: ");
				}

				// Daten vom letzten Paket ggf. fortsetzen
				for (int i = 0; i < dataLength; i++) {
					logMsg(((Short)data[i]).toString());
				}

				if (!moreData) {
					// alles gesendet - Meldung abschließen
					logMsgln("");
				}
				break;

			default:
				logMsgln("WARN: Received undefined message.");
				if (debug) { logMsgln("Undefined: " + nm.toString()); }
				break;
		}

		moreData = nm.get_moreData() == 0 ? false : true;
		return;
	}

	private void logMsg(String m) {
		if (logFile != null) {
			logFile.print(m);
		} else {
			System.out.print(m);
		}
	}

	private void logMsgln(String m) {
		if (logFile != null) {
			logFile.println(m);
		} else {
			System.out.println(m);
		}
	}

	private void printHelp() {
		PrintStream ps = System.out;
		ps.println("Mote commands:");
		ps.println("  echo ID [further IDs]");
		ps.println("  ledon ID red/green/blue");
		ps.println("  ledoff ID red/green/blue");
		ps.println("  ledtoggle ID red/green/blue");
		ps.println("  ledblink ID red/green/blue times");
		ps.println("  newms ID1 ID2 measure_set measure_count");
		ps.println("  startms ID1 ID2");
		ps.println("  stopms ID1 ID2");
		ps.println("  clearms ID1 ID2");
		ps.println();
		ps.println("Local commands:");
		ps.println("  quit/exit");
		ps.println("  help");
		ps.println("  setlog <file>/none");
		ps.println("  printlog [last n lines]");
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

