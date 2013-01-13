interface LcdControl
{
  event void button1Pressed(void);
  event void button2Pressed(void);
  command void puts(const char *s);
}
