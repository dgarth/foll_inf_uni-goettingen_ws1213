configuration AmpelAppC {
}
implementation {
  components MainC, AmpelC, LedsC;
  components new TimerMilliC() as Timer0;

  AmpelC.MyTimer -> Timer0.Timer;
  AmpelC.Horst -> LedsC.Leds;
  AmpelC.Boot -> MainC.Boot;
}

