//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1

interface LcdControl
{
  /*Button-events*/
  event void button1Pressed(void);
  event void button2Pressed(void);
  /*Communication established ;)*/
  event void lcdEnabled(void);
  
  /*Einen String auf dem Disp (im naechsten Durchlauf) ausgeben*/
  command void puts(const char *s, uint8_t line);
  /*Pieps*/
  command void beep(void);
  /*Leds am Board*/
  command void led0Toggle(void);
  command void led1Toggle(void);
  /*Kommunikation mit LCD ein (alle 100 ms)*/
  command void enable(void);
  /*wieder abschalten*/
  command void disable(void);
}
