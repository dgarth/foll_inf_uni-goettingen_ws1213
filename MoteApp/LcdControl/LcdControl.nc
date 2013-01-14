interface LcdControl
{
  event void button1Pressed(void);
  event void button2Pressed(void);
  command void puts(const char *s, uint8_t line);
  command void beep();
  command void led0Toggle();
  command void led1Toggle();
}
