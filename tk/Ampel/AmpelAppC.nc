//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1
}
implementation {
  components MainC, AmpelC, LedsC;
  components new TimerMilliC() as Timer0;

  AmpelC.MyTimer -> Timer0.Timer;
  AmpelC.Horst -> LedsC.Leds;
  AmpelC.Boot -> MainC.Boot;
}

