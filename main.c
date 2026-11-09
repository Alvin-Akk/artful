#include <msp430.h>
#include "led.h"

int main(void)
{
    volatile unsigned long i;
    WDTCTL = WDTPW + WDTHOLD; // Stop watchdog timer
    led_init();

    while(1)
    {
        led_toggle();
        for (i=30000; i>0; i--); // Led blink
    }
}

