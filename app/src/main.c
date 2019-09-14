#include <stdint.h>
#include "stdio.h"
    void Soft_Delay(volatile uint32_t number)
    {
            while(number--);
    }



    int main(void)
    {

    int a = 0;
        while (1) {
        a++;
        Soft_Delay(10000);
        }
    }


    void SystemInit(void)
    {
        Soft_Delay(10000);
    }
