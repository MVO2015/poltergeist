#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <pigpio.h>
#include <signal.h>
#include <time.h>
#include <string.h>

#define short_pulse  1000
#define long_pulse  (2 * short_pulse)
#define PIN_INPUT_RF433 9
#define PIN_LED_GREEN 4
#define PIN_LED_AMBER 17
#define PIN_LED_RED 27
#define THERMOSTAT_ADDR "10011"
#define FILE_NAME "heating.dat"
#define LOG_FILE_NAME "/var/log/poltergeist/sensors.log"

volatile sig_atomic_t stop;

void inthand(int signum) {
    stop = 1;
}

uint32_t last_tick;
int wait_for_start = 0;
int wait_for_end = 1;
int bitCounter = 0;
char bitRegister[13] = {'0','0','0','0','0','0','0','0','0','0','0','0', '\0' };
char *thermostat = THERMOSTAT_ADDR "011";
char *value_off = "0100";
char *value_on = "0010";
char *text_off = "OFF";
char *text_on = "ON";
char *value_batt_full = "0110";
char *text_batt_full = "Battery full";

time_t rawtime, last_time = 0, command_recognized_time, insert_data_time;
struct tm * timeinfo;
char timestr[20]; // YYYY-MM-DD HH:MM:SS\0
char *last_command, *actual_command;
int data_packet_repeats;
FILE *fptr, *logptr;

int startsWith(const char *pre, const char *str)
{
    size_t lenpre = strlen(pre), lenstr = strlen(str);
    return lenstr < lenpre ? 0 : strncmp(pre, str, lenpre) == 0;
}

char *getTime(time_t timer)
{
    timeinfo = localtime(&timer);
    strftime(timestr, 20, "%F %T", timeinfo);
    return timestr;
}

void myISR(int gpio, int level, uint32_t tick)
{
    uint32_t tick_diff;
    char *text;

    // Start pulse
    if (1 == level) {
        last_tick = tick;
        return;
    }
    // End frame
    if (2 == level && !wait_for_start) {
        tick_diff = tick - last_tick;
        if (tick_diff > (2 * long_pulse)) {
            wait_for_end = 0;
            wait_for_start = 1;
            gpioWrite(PIN_LED_AMBER, 0);
            if (bitCounter != 12) {
                // Bad packet, ignoring
                return;
            }
            if (!startsWith(thermostat, bitRegister)) {
                // bad address
                return;
            }

            int command_recognized = 1;
            if (strcmp(&bitRegister[8], value_on) == 0) {
                text = text_on;
                gpioWrite(PIN_LED_RED, 1);
                gpioWrite(PIN_LED_GREEN, 0);
                actual_command = value_on;
            } else if (strcmp(&bitRegister[8], value_off) == 0) {
                text = text_off;
                gpioWrite(PIN_LED_RED, 0);
                gpioWrite(PIN_LED_GREEN, 1);
                actual_command = value_off;
            } else if (strcmp(&bitRegister[8], value_batt_full) == 0) {
                text = text_batt_full;
            } else {
                gpioWrite(PIN_LED_RED, 1);
                gpioWrite(PIN_LED_GREEN, 1);
                text = "UNKNOWN COMMAND";
                command_recognized = 0;
            }

            if (command_recognized) {
                command_recognized_time = time(NULL);

                if ((command_recognized_time - last_time > 59) || actual_command != last_command) {
                    last_command = actual_command;
                    last_time = command_recognized_time;
                    if (strcmp(text, text_on) == 0) {
                        fseek(fptr, 0, SEEK_SET);
                        fprintf(fptr, "%lu:1", command_recognized_time);
                        fflush(fptr);
                    }
                    if (strcmp(text, text_off) == 0) {
                        fseek(fptr, 0, SEEK_SET);
                        fprintf(fptr, "%lu:0", command_recognized_time);
                        fflush(fptr);
                    }
                    fseek(logptr, -1, SEEK_END);
                    if (fgetc(logptr) != '\n') {
                        fprintf(logptr, "\n");
                        }
                    fprintf(logptr, "%lu,THERMOSTAT,%s,%s,", time(&command_recognized_time), bitRegister, text);
                    fflush(logptr);
                }

                if ((command_recognized_time - last_time < 1) && actual_command == last_command) {
                    last_time = command_recognized_time;
                    fprintf(logptr, "+");
                    fflush(logptr);
                }
            }
        }
    }
    if (0 == level) {
        tick_diff = tick - last_tick;
        gpioWrite(PIN_LED_AMBER, 0);

        // Start frame
        if (wait_for_start && !wait_for_end && tick_diff < short_pulse) {
            wait_for_start = 0;
            bitCounter = 0;
            gpioWrite(PIN_LED_AMBER, 1);
	    return;
        }

        if (!wait_for_start && !wait_for_end) {
            if (bitCounter > 11) {
                // Overflow error, ignoring packet
                wait_for_end = 1;
                return;
            }
            if (tick_diff < short_pulse) {
                bitRegister[bitCounter] = '0';
            } else {
                bitRegister[bitCounter] = '1';
            }
            bitCounter++;
        }
    }
}

void setup()
{
    gpioSetSignalFunc(SIGINT, inthand);
    gpioSetMode(PIN_LED_GREEN, PI_OUTPUT);
    gpioSetMode(PIN_LED_AMBER, PI_OUTPUT);
    gpioSetMode(PIN_LED_RED, PI_OUTPUT);
    gpioWrite(PIN_LED_RED, 0);
    gpioWrite(PIN_LED_AMBER, 0);
    gpioWrite(PIN_LED_GREEN, 0);
    gpioWrite(PIN_INPUT_RF433, 0);
    gpioSetMode(PIN_INPUT_RF433, PI_INPUT);
    gpioGlitchFilter(PIN_INPUT_RF433, short_pulse / 2);
    if (gpioSetAlertFunc(PIN_INPUT_RF433, myISR ) < 0) {
        fprintf(stderr, "Set Alert Error!\n");
    }
    if (gpioSetWatchdog(PIN_INPUT_RF433, long_pulse * 2 / 1000) < 0) {
        fprintf(stderr, "Set Watchdog error!\n");
    }
    last_time = time(NULL) - 61;
    last_tick = gpioTick();
    fptr = fopen(HOME "/" FILE_NAME, "w");
    if (fptr == NULL) {
        fprintf(stderr, "Error - cannot open file %s\n", HOME "/" FILE_NAME);
        exit(1);
    }

    logptr = fopen(LOG_FILE_NAME, "a+");
    if (logptr == NULL) {
        fprintf(stderr, "Error - cannot open file '" LOG_FILE_NAME "\n");
        exit(1);
    }
    printf("All is OK!\n");
    printf("Home is '%s'.\n", HOME); 
    printf("Logging to '%s'.\n", LOG_FILE_NAME);
    fflush(stdout);
}

void cleanup()
{
    gpioSetSignalFunc(SIGINT, NULL);
    gpioSetAlertFunc(PIN_INPUT_RF433, NULL);
    gpioSetWatchdog(PIN_INPUT_RF433, 0);
    gpioWrite(PIN_LED_AMBER, 0);
    gpioWrite(PIN_LED_GREEN, 0);
    gpioWrite(PIN_LED_RED, 0);
    gpioSetMode(PIN_LED_AMBER, PI_INPUT);
    gpioSetMode(PIN_LED_GREEN, PI_INPUT);
    gpioSetMode(PIN_LED_RED, PI_INPUT);
    gpioTerminate();
    fclose(fptr);
    fclose(logptr);
}

int main()
{
    time_t actual_time;

    if (gpioInitialise() < 0) {
        // pigpio initialisation failed.
        return 1;
    }

    setup();

    while(!stop) {
        actual_time = time(NULL);
        if (difftime(actual_time, last_time) > 61.0) {
            gpioWrite(PIN_LED_GREEN, 0);
            gpioWrite(PIN_LED_GREEN, 0);
            gpioWrite(PIN_LED_AMBER, 1);
        }
        usleep(500000);
        gpioWrite(PIN_LED_AMBER, 0);
        usleep(500000);
    }

    printf("\nExiting safely\n");
    cleanup();
    return 0;
}
