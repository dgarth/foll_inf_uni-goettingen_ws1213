interface LcdControl
{
  event void button1Pressed(void);
  event void button2Pressed(void);
  event void lcdReady(void);
  command void buttonRequest(void);
  command void puts(const char *s, uint8_t line);
  command void beep(void);
  command void led0Toggle(void);
  command void led1Toggle(void);
  command void checkReady();
}
