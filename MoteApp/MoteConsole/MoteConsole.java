import java.io.*;
import java.util.*;
import java.util.concurrent.Semaphore;
import java.util.regex.Pattern;


import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class MoteConsole implements MessageListener {

    private final int MAX_DATA = 10;
    private boolean debug;
    private boolean localCmd;
    private MoteIF moteIF; // serielles Interface
    private NodeMsg nodeMsgObj; // gesendetes/empfangenes Paket
    boolean moreData; // aktuelles Paket ist unvollständig
    Semaphore outLock; // Synchronisation der Ausgabe
    private PrintStream logFile;
    private String logPath;
    private BatchMeasure batch;


    /*==================*
     * init & main loop *
     *==================*/

    public MoteConsole(MoteIF moteIF) {
        this.debug = false;
        this.localCmd = false;
        this.moteIF = moteIF;
        this.nodeMsgObj = new NodeMsg();
        this.moreData = false;
        this.outLock = new Semaphore(1);
        this.logFile = null;
        this.logPath = null;
        this.batch = new BatchMeasure();

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

        for (; true; outLock.release()) {

            try {
                outLock.acquire();
            }
            catch (InterruptedException ex) {}

            // prompt & read
            System.out.print("> ");

            // gracefully handle EOF
            try {
                input = sc.nextLine();
            }
            catch (NoSuchElementException ex) {
                break;
            }

            tokens = input.split(" ");

            // tokens.length ist immer > 0
            if (tokens[0].equals("")) {
                continue;
            }

            if ("help".startsWith(tokens[0])) {
                printHelp();
                continue;
            }
            else if ("quit".startsWith(tokens[0]) || "exit".startsWith(tokens[0])) {
                outLock.release();
                break;
            }

            /*-----*
             * log *
             *-----*/
            else if (Pattern.matches("^log?$", tokens[0])) {
                if (tokens.length < 2) {
                    System.out.println("usage: log <command> [<arg>]");
                    continue;
                }
                if ("set".startsWith(tokens[1])) {
                    setLogfile(tokens.length >= 3 ? tokens[2] : null);
                }

                if ("print".startsWith(tokens[1])) {
                    printLogfile(tokens.length == 3 ? tokens[2] : null);
                }
            }

            /*------*
             * echo *
             *------*/
            else if ("echo".startsWith(tokens[0])) {
                if (tokens.length < 2) {
                    System.out.println("usage: echo <node>");
                    continue;
                }
                sendMsg(MoteCommands.CMD_ECHO, tokens[1]);
            }

            /*------*
             * LEDs *
             *------*/
            else if (Pattern.matches("^led?$", tokens[0])) {
                int cmd = -1;
                long id, led;

                if (tokens.length < 4) {
                    System.out.println("usage: led <command> <node> <color>");
                    continue;
                }

                if (tokens[1].equals("on")) {
                    cmd = MoteCommands.CMD_LEDON;
                }
                else if (Pattern.matches("off?", tokens[1])) {
                    cmd = MoteCommands.CMD_LEDOFF;
                }
                else if ("toggle".startsWith(tokens[1])) {
                    cmd = MoteCommands.CMD_LEDTOGGLE;
                }
                else if ("blink".startsWith(tokens[1])) {
                    cmd = MoteCommands.CMD_LEDBLINK;
                }

                if (cmd == -1) {
                    System.out.println("invalid led command");
                }

                try {
                    id = Long.parseLong(tokens[2]);
                }
                catch (Exception e) {
                    System.out.println("node ID must be an integer");
                    continue;
                }

                led = ledFromString(tokens[3]);
                if (led == 0) {
                    System.out.println("invalid LED color, must be \"green\", \"red\" or \"blue\"");
                    continue;
                }

                sendMsg(cmd, id, led);
            }

            /*---------*
             * measure *
             *---------*/
            else if ("ms".startsWith(tokens[0])) {
                int cmd = -1;
                String[] args;

                if (tokens.length < 4) {
                    System.out.println("usage: ms <command> <node1> <node2> [<args ...>]");
                    continue;
                }

                if ("new".startsWith(tokens[1])) {
                    cmd = MoteCommands.CMD_NEWMS;
                }
                else if (Pattern.matches("sta(rt?)?", tokens[1])) {
                    cmd = MoteCommands.CMD_STARTMS;
                }
                else if (Pattern.matches("stop?", tokens[1])) {
                    cmd = MoteCommands.CMD_STOPMS;
                }
                else if ("clear".startsWith(tokens[1])) {
                    cmd = MoteCommands.CMD_CLEARMS;
                }
                else {
                    System.out.println("invalid ms command");
                }

                if (cmd != -1) {
                    args = Arrays.copyOfRange(tokens, 2, tokens.length);
                    sendMsg(cmd, args);
                }
            }

            /*-------*
             * batch *
             *-------*/
            else if ("batch".startsWith(tokens[0])) {
                if (tokens.length < 2) {
                    System.out.println("usage: batch <command> [<args>]");
                    continue;
                }

                if ("load".startsWith(tokens[1])) {
                    if (tokens.length < 3) {
                        System.out.println("usage: batch load <file>");
                        continue;
                    }
                    // load batch measure file
                    batch.load(tokens[2]);
                }

                else if ("clear".startsWith(tokens[1])) {
                    // remove all items from batch queue
                    batch.clear();
                }

                else if ("next".startsWith(tokens[1])) {
                    // send NEWMS and STARTMS with values from the next line
                    long next[] = batch.next();
                    if (next != null) {
                        System.out.printf(
                                "Starting measure %d with nodes %d and %d (%d packets)\n",
                                next[2], next[0], next[1], next[3]);
                        sendMsg(makeMsg(MoteCommands.CMD_NEWMS, next));
                        try { Thread.sleep(500); } catch (InterruptedException e) { ; }
                        sendMsg(makeMsg(MoteCommands.CMD_STARTMS, next));
                    } else {
                        System.out.println("Nothing to do");
                    }
                }

                else {
                    System.out.println("invalid batch command");
                }
            }

            else {
                System.out.println("invalid command");
            }
        }
    }

    private void printHelp() {
        PrintStream ps = System.out;
        ps.println("Mote commands:");
        ps.println("  echo ID [further IDs]");
        ps.println("  led on ID red/green/blue");
        ps.println("  led off ID red/green/blue");
        ps.println("  led toggle ID red/green/blue");
        ps.println("  led blink ID red/green/blue times");
        ps.println("  ms new ID1 ID2 measure_set measure_count");
        ps.println("  ms start ID1 ID2");
        ps.println("  ms stop ID1 ID2");
        ps.println("  ms clear ID1 ID2");
        ps.println("  batch load FILE - load batch measures from FILE");
        ps.println("  batch next      - start next batch measure");
        ps.println("  batch clear     - clear all batch measures ");
        ps.println();
        ps.println("Local commands:");
        ps.println("  quit/exit");
        ps.println("  help");
        ps.println("  log set <file>/none");
        ps.println("  log print [last n lines]");
        ps.println();
        ps.println("Commands can be abbreviated");
        ps.println("e.g. \"le t\" for \"led toggle\"");
    }


    /*=======*
     * misc. *
     *=======*/

    private long ledFromString(String s) {
        if ("red".startsWith(s)) {
            return 1;
        }
        else if ("green".startsWith(s)) {
            return 2;
        }
        else if ("blue".startsWith(s)) {
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


    /*=======================*
     * build & send commands *
     *=======================*/

    public NodeMsg makeMsg(int cmd, long... data) {
        NodeMsg msg = new NodeMsg();
        short[] buf = new short[MAX_DATA];
        String format;
        int length;

        switch (cmd) {
            case MoteCommands.CMD_ECHO:
                format = "B";
                break;

            case MoteCommands.CMD_LEDON:
            case MoteCommands.CMD_LEDOFF:
            case MoteCommands.CMD_LEDTOGGLE:
            case MoteCommands.CMD_LEDBLINK:

            case MoteCommands.CMD_STARTMS:
            case MoteCommands.CMD_STOPMS:
            case MoteCommands.CMD_CLEARMS:
                format = "BB";
                break;

            case MoteCommands.CMD_NEWMS:
                format = "BBHH";
                break;

            default:
                throw new IllegalArgumentException("invalid command");
        }

        try {
            length = Pack.pack(buf, format, data);
        }
        catch (ArrayIndexOutOfBoundsException e) {
            throw new IllegalArgumentException("not enough parameters");
        }
        msg.set_cmd((short) cmd);
        msg.set_data(buf);
        msg.set_length((short) length);
        msg.set_moreData((short) 0);
        return msg;
    }

    public NodeMsg makeMsg(int cmd, String... data) {
        long[] d = new long[data.length];

        for (int i = 0; i < data.length; i++) {
            try {
                d[i] = Long.parseLong(data[i]);
            }
            catch (NumberFormatException e) {
                System.out.println("invalid argument: \"" + data[i] + "\" is not a number");
                return null;
            }
        }

        return makeMsg(cmd, d);
    }

    private void sendMsg(NodeMsg msg) {
        if (msg == null) {
            return;
        }

        try {
            if (debug) {
                System.out.println("sending: " + msg.toString());
            }
            if (this.moteIF != null) {
                moteIF.send(0, msg);
            }
        }
        catch (IOException ex) {
            System.out.println(ex.toString());
        }
    }

    private void sendMsg(int cmd, long... data) {
        try {
            sendMsg(makeMsg(cmd, data));
        }
        catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }

    private void sendMsg(int cmd, String... data) {
        try {
            sendMsg(makeMsg(cmd, data));
        }
        catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }


    /*==================*
     * receive messages *
     *==================*/

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
                long res[] = Pack.unpack(data, "BBHHb");
                String fmt = String.format(
                        "Measure #%d from set %d [%d --> %d], RSSI = %d",
                        res[3], res[2], res[0], res[1], res[4]);
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
}
