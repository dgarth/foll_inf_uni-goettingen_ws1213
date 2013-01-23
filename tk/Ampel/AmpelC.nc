//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1
  uses interface Timer<TMilli> as MyTimer;
  uses interface Leds as Horst;
  uses interface Boot;
}
implementation {
  uint8_t count = 0;

  event void Boot.booted()
  {
  	call Horst.led0On();
    	call MyTimer.startPeriodic(500);
  }

  event void MyTimer.fired()
  {
	/* start mit rot (led0) */
	switch (count) {
	  case 0: /* rot (001) */
	    call Horst.set(1);
	    break;
	  case 5: /* rot-gelb (011) */
	    call Horst.set(3);
	    break;
	  case 6: /* gruen (100) */
	    call Horst.set(4);
	  break;
	  case 12: /* gelb (010) */
	    call Horst.set(2);
	  break;
	}

	count++;
	count %= 15; /* 12 + 2 ticks fuer die gelbphase (13 + 14)  */
  }
}

