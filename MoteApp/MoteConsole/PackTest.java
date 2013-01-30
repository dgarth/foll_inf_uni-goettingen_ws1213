
public class PackTest
{
    public static void test1()
    {
       short[] buf = Pack.Pack("bBb", -5, 253, -7);
       long[] vals = Pack.Unpack("bBb", buf);

       assert vals[0] == -5;
       assert vals[1] == 254;
       assert vals[2] == -7;
    }

    public static void test2()
    {
       short[] buf = Pack.Pack("h_Hh", -5500, 25400, -7);
       long[] vals = Pack.Unpack("h_Hh", buf);

       assert vals[0] == -5500;
       assert vals[1] == 25400;
       assert vals[2] == -7;
    }

    public static void test3()
    {
       short[] buf = Pack.Pack("ibI", -5500, -253, 25400);
       long[] vals = Pack.Unpack("ibI", buf);

       assert vals[0] == -5500;
       assert vals[1] == -253;
       assert vals[2] == 25400;
    }

    public static void test4()
    {
       short[] buf = Pack.Pack("l", Long.MIN_VALUE);
       long[] vals = Pack.Unpack("l", buf);

       assert vals[0] == Long.MIN_VALUE;
    }

    public static void main(String[] args)
    {
        test1();
        test2();
        test3();
        test4();
    }
}
