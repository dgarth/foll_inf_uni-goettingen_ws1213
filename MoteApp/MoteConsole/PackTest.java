
public class PackTest
{
    public static void test1()
    {
       short[] buf = new short[10];
       Pack.pack(buf, "bBb", -5, 253, -7);
       long[] vals = Pack.unpack(buf, "bBb");

       assert vals[0] == -5;
       assert vals[1] == 254;
       assert vals[2] == -7;
    }

    public static void test2()
    {
       short[] buf = new short[20];
       Pack.pack(buf, "bIBh", -5, 99999, 1, -7500);
       long[] vals = Pack.unpack(buf, "bI_h");

       assert vals[0] == -5;
       assert vals[1] == 99999;
       assert vals[2] == -7500;
    }

    public static void main(String[] args)
    {
        test1();
        test2();
    }
}
