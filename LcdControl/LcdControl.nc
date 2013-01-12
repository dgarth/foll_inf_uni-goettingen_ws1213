interface LcdControl
{
  event void button1Pressed(void);
  event void button2Pressed(void);
  command void print(const char *s1, const char *s2);
}
