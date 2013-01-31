import java.util.*;

public class Pack
{
    public static int pack(short[] buf, String fmt, long... values)
    {
        int totalsz = 0;

        if (fmt.indexOf("L") != -1) {
            System.err.println("L is not supported!");
            return 0;
        }

        for (int i = 0, ivals = 0; i < fmt.length(); i++) {
            long val = 0;
            int sz = 0;

            if ("_bBhHiIl".indexOf(fmt.charAt(i)) == -1) {
                continue;
            }

            switch (fmt.charAt(i)) {
                case '_':
                    val = 0;
                    sz = 1;
                    break;

                case 'b':
                    val = (byte) values[ivals];
                    sz = 1;
                    break;
                case 'B':
                    val = (short) promote(values[ivals], Byte.MAX_VALUE);
                    sz = 1;
                    break;

                case 'h':
                    val = (short) values[ivals];
                    sz = 2;
                    break;
                case 'H':
                    val = (int) promote(values[ivals], Short.MAX_VALUE);
                    sz = 2;
                    break;

                case 'i':
                    val = (int) values[ivals];
                    sz = 4;
                    break;
                case 'I':
                    val = promote(values[ivals], Integer.MAX_VALUE);
                    sz = 4;
                    break;

                case 'l':
                case 'L':
                    val = values[ivals];
                    sz = 8;
                    break;
            }
            bufferPut(buf, val, totalsz, sz);
            totalsz += sz;
            ivals += 1;
        }

        return totalsz;
    }

    public static long[] unpack(short[] buf, String fmt)
    {
        if (fmt.indexOf("L") != -1) {
            System.err.println("L is not supported!");
            return null;
        }

        long[] vals = new long[fmt.replaceAll("[^bBhHiIl]", "").length()];


        for (int i = 0, ibuf = 0, ivals = 0; i < fmt.length(); i++) {
            int sz = 0;

            if (fmt.charAt(i) == '_') {
                ibuf += 1;
                continue;
            }

            switch (fmt.charAt(i)) {
                case 'b':
                    sz = 1;
                    vals[ivals] = ((byte)bufferGet(buf, ibuf, sz));
                    break;
                case 'B':
                    sz = 1;
                    vals[ivals] = bufferGet(buf, ibuf, sz);
                    break;

                case 'h':
                    sz = 2;
                    vals[ivals] = ((short)bufferGet(buf, ibuf, sz));
                    break;
                case 'H':
                    sz = 2;
                    vals[ivals] = bufferGet(buf, ibuf, sz);
                    break;

                case 'i':
                    sz = 4;
                    vals[ivals] = ((int)bufferGet(buf, ibuf, sz));
                    break;
                case 'I':
                    sz = 4;
                    vals[ivals] = bufferGet(buf, ibuf, sz);
                    break;

                case 'L':
                    sz = 8;
                    vals[ivals] = bufferGet(buf, ibuf, sz);
                    break;
            }

            ibuf += sz;
            ivals += 1;
        }

        return vals;
    }

    private static int neededBytes(String fmt)
    {
        int n = 0;
        for (char c : fmt.toCharArray()) {
            switch (Character.toUpperCase(c)) {
                case '_':
                case 'B':
                    n += 1;
                    break;
                case 'H':
                    n += 2;
                    break;
                case 'I':
                    n += 4;
                    break;
                case 'L':
                    n += 8;
                    break;
            }
        }
        return n;
    }

    private static void bufferPut(short[] buf, long value, int start, int size)
    {
        while (size-- > 0) {
            buf[start + size] = (short) (value & 0xFF);
            value >>>= 8;
        }
    }

    private static long bufferGet(short[] buf, int start, int size)
    {
        long value = 0;

        for (int i = 0; i < size; i++) {
            value <<= 8;
            value += buf[start+i];
        }

        return value;
    }

    private static long promote(long val, long add)
    {
        while (val < 0)
        {
            val += add;
            val += 1;
        }

        return val;
    }

}
