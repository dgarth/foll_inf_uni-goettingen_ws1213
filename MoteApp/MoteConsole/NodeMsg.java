/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'NodeMsg'
 * message type.
 */

public class NodeMsg extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 28;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 137;

    /** Create a new NodeMsg of size 28. */
    public NodeMsg() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new NodeMsg of the given data_length. */
    public NodeMsg(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new NodeMsg with the given data_length
     * and base offset.
     */
    public NodeMsg(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new NodeMsg using the given byte array
     * as backing store.
     */
    public NodeMsg(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new NodeMsg using the given byte array
     * as backing store, with the given base offset.
     */
    public NodeMsg(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new NodeMsg using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public NodeMsg(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new NodeMsg embedded in the given message
     * at the given base offset.
     */
    public NodeMsg(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new NodeMsg embedded in the given message
     * at the given base offset and length.
     */
    public NodeMsg(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <NodeMsg> \n";
      try {
        s += "  [cmd=0x"+Long.toHexString(get_cmd())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [data=";
        for (int i = 0; i < 25; i++) {
          s += "0x"+Long.toHexString(getElement_data(i) & 0xff)+" ";
        }
        s += "]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [length=0x"+Long.toHexString(get_length())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [moreData=0x"+Long.toHexString(get_moreData())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: cmd
    //   Field type: short, unsigned
    //   Offset (bits): 0
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'cmd' is signed (false).
     */
    public static boolean isSigned_cmd() {
        return false;
    }

    /**
     * Return whether the field 'cmd' is an array (false).
     */
    public static boolean isArray_cmd() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'cmd'
     */
    public static int offset_cmd() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'cmd'
     */
    public static int offsetBits_cmd() {
        return 0;
    }

    /**
     * Return the value (as a short) of the field 'cmd'
     */
    public short get_cmd() {
        return (short)getUIntBEElement(offsetBits_cmd(), 8);
    }

    /**
     * Set the value of the field 'cmd'
     */
    public void set_cmd(short value) {
        setUIntBEElement(offsetBits_cmd(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'cmd'
     */
    public static int size_cmd() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'cmd'
     */
    public static int sizeBits_cmd() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: data
    //   Field type: short[], unsigned
    //   Offset (bits): 8
    //   Size of each element (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'data' is signed (false).
     */
    public static boolean isSigned_data() {
        return false;
    }

    /**
     * Return whether the field 'data' is an array (true).
     */
    public static boolean isArray_data() {
        return true;
    }

    /**
     * Return the offset (in bytes) of the field 'data'
     */
    public static int offset_data(int index1) {
        int offset = 8;
        if (index1 < 0 || index1 >= 25) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 8;
        return (offset / 8);
    }

    /**
     * Return the offset (in bits) of the field 'data'
     */
    public static int offsetBits_data(int index1) {
        int offset = 8;
        if (index1 < 0 || index1 >= 25) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 8;
        return offset;
    }

    /**
     * Return the entire array 'data' as a short[]
     */
    public short[] get_data() {
        short[] tmp = new short[25];
        for (int index0 = 0; index0 < numElements_data(0); index0++) {
            tmp[index0] = getElement_data(index0);
        }
        return tmp;
    }

    /**
     * Set the contents of the array 'data' from the given short[]
     */
    public void set_data(short[] value) {
        for (int index0 = 0; index0 < value.length; index0++) {
            setElement_data(index0, value[index0]);
        }
    }

    /**
     * Return an element (as a short) of the array 'data'
     */
    public short getElement_data(int index1) {
        return (short)getUIntBEElement(offsetBits_data(index1), 8);
    }

    /**
     * Set an element of the array 'data'
     */
    public void setElement_data(int index1, short value) {
        setUIntBEElement(offsetBits_data(index1), 8, value);
    }

    /**
     * Return the total size, in bytes, of the array 'data'
     */
    public static int totalSize_data() {
        return (200 / 8);
    }

    /**
     * Return the total size, in bits, of the array 'data'
     */
    public static int totalSizeBits_data() {
        return 200;
    }

    /**
     * Return the size, in bytes, of each element of the array 'data'
     */
    public static int elementSize_data() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of each element of the array 'data'
     */
    public static int elementSizeBits_data() {
        return 8;
    }

    /**
     * Return the number of dimensions in the array 'data'
     */
    public static int numDimensions_data() {
        return 1;
    }

    /**
     * Return the number of elements in the array 'data'
     */
    public static int numElements_data() {
        return 25;
    }

    /**
     * Return the number of elements in the array 'data'
     * for the given dimension.
     */
    public static int numElements_data(int dimension) {
      int array_dims[] = { 25,  };
        if (dimension < 0 || dimension >= 1) throw new ArrayIndexOutOfBoundsException();
        if (array_dims[dimension] == 0) throw new IllegalArgumentException("Array dimension "+dimension+" has unknown size");
        return array_dims[dimension];
    }

    /**
     * Fill in the array 'data' with a String
     */
    public void setString_data(String s) { 
         int len = s.length();
         int i;
         for (i = 0; i < len; i++) {
             setElement_data(i, (short)s.charAt(i));
         }
         setElement_data(i, (short)0); //null terminate
    }

    /**
     * Read the array 'data' as a String
     */
    public String getString_data() { 
         char carr[] = new char[Math.min(net.tinyos.message.Message.MAX_CONVERTED_STRING_LENGTH,25)];
         int i;
         for (i = 0; i < carr.length; i++) {
             if ((char)getElement_data(i) == (char)0) break;
             carr[i] = (char)getElement_data(i);
         }
         return new String(carr,0,i);
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: length
    //   Field type: short, unsigned
    //   Offset (bits): 208
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'length' is signed (false).
     */
    public static boolean isSigned_length() {
        return false;
    }

    /**
     * Return whether the field 'length' is an array (false).
     */
    public static boolean isArray_length() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'length'
     */
    public static int offset_length() {
        return (208 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'length'
     */
    public static int offsetBits_length() {
        return 208;
    }

    /**
     * Return the value (as a short) of the field 'length'
     */
    public short get_length() {
        return (short)getUIntBEElement(offsetBits_length(), 8);
    }

    /**
     * Set the value of the field 'length'
     */
    public void set_length(short value) {
        setUIntBEElement(offsetBits_length(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'length'
     */
    public static int size_length() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'length'
     */
    public static int sizeBits_length() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: moreData
    //   Field type: short, unsigned
    //   Offset (bits): 216
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'moreData' is signed (false).
     */
    public static boolean isSigned_moreData() {
        return false;
    }

    /**
     * Return whether the field 'moreData' is an array (false).
     */
    public static boolean isArray_moreData() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'moreData'
     */
    public static int offset_moreData() {
        return (216 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'moreData'
     */
    public static int offsetBits_moreData() {
        return 216;
    }

    /**
     * Return the value (as a short) of the field 'moreData'
     */
    public short get_moreData() {
        return (short)getUIntBEElement(offsetBits_moreData(), 8);
    }

    /**
     * Set the value of the field 'moreData'
     */
    public void set_moreData(short value) {
        setUIntBEElement(offsetBits_moreData(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'moreData'
     */
    public static int size_moreData() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'moreData'
     */
    public static int sizeBits_moreData() {
        return 8;
    }

}
