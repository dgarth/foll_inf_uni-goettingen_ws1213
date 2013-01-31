import java.io.*;
import java.util.*;

public class BatchMeasure
{

    private Queue<long[]> commands;
    private long lineno;

    public BatchMeasure()
    {
        commands = new LinkedList<long[]>();
        lineno = 0;
    }

    /* load batch measure data from file. format:

        # COMMENT
        NODE1 NODE2 COUNT
        NODE1 NODE2 COUNT
        [...]
    */
    public void load(String filename)
    {
        try {
            String line;
            BufferedReader in = new BufferedReader(new FileReader(filename));

            while ((line = in.readLine()) != null) {
                // skip comments
                if (line.startsWith("#")) {
                    continue;
                }

                String[] args = line.split(" ");

                // skip invalid input lines
                if (args.length != 3) {
                    System.err.println("inalid input: " + line);
                    continue;
                }

                long cmd[] = new long[4];
                cmd[0] = Long.parseLong(args[0]);
                cmd[1] = Long.parseLong(args[1]);
                cmd[2] = this.lineno++;
                cmd[3] = Long.parseLong(args[2]);
                this.commands.add(cmd);
            }
        }
        catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }

    public void clear()
    {
        this.lineno = 0;
        this.commands.clear();
    }

    /* pop the next values from the queue */
    public long[] next()
    {
        try {
            return this.commands.remove();
        }
        catch (NoSuchElementException e) {
            return null;
        }
    }

}
