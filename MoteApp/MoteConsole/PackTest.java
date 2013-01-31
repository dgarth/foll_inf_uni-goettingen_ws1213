
public class PackTest
{
    public static void test1()
    {
       short[] buf = new short[10];
       Pack.pack(buf, "bBb", -5, 253, -7);
       long[] vals = Pack.unpack(buf, "bBb");

       assert vals[0] == -5;
       assert vals[1] == 253;
       assert vals[2] == -7;
    }

    public static void test2()
    {
       short[] buf = new short[20];
       Pack.pack(buf, "BBHH", 1, 2, 30, 40);
       long[] vals = Pack.unpack(buf, "BBHH");

       assert vals[0] == 1;
       assert vals[1] == 2;
       assert vals[2] == 30;
       assert vals[3] == 40;
    }

    public static void main(String[] args)
    {
        test1();
        test2();
    }
}
