#include <stdio.h>
#include <unistd.h>

static char* PINS[6] = {
    "PIN0",
    "PIN1",
    "PIN2",
    "PIN3",
    "PIN4",
    "PIN5"
};

static char * MODES[2] = {
    "INPUT",
    "OUTPUT"
};

static int PIN_STATUS[6] = {0,0,0,0,0,0};
static int PIN_MODES[6] = {0,0,0,0,0,0};

int wiringPiSetup(){
    printf("***** LED DEBUG MODE\n");
    return 0;
}

void delay(int ms){
    printf("***** DELAY %ds\n", ms);
    sleep(ms/1000);
}

void digitalWrite(int pin, int val){
    if(PIN_MODES[pin]){
        printf("***** PIN %s SET TO %d\n", PINS[pin], val);
        PIN_STATUS[pin] = !!val;
    }
    else {
        printf("***** ATTEMPT TO SET %s TO %d FAILED\n", PINS[pin], val);
    }
    
}

void pinMode(int pin, int mode){
    mode = !!mode;
    printf("***** PIN %s MODE SET TO %s\n", PINS[pin], MODES[mode]);
    PIN_MODES[pin] = mode;
}
