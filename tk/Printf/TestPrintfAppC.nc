//vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1
//       warning about the new printf semanics.  Just all the following line:
//       CFLAGS += -DNEW_PRINTF_SEMANTICS
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration TestPrintfAppC{
}
implementation {
  components MainC, TestPrintfC;
  components new TimerMilliC();
  components PrintfC;
  components SerialStartC;

  TestPrintfC.Boot -> MainC;
  TestPrintfC.Timer -> TimerMilliC;
}

