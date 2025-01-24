/*
// This #include statement was automatically added by the Particle IDE.
#include "lib1.h"

// Include Particle Device OS APIs
#include "Particle.h"

#define SERVO_PIN D2
// Let Device OS manage the connection to the Particle CloudH
SYSTEM_MODE(AUTOMATIC);

// Pin number for the external LED
const int externalLEDPin = D2;  // Change to your desired pin (D2 in this case)

bool windowOpened;
bool taskRunning;
Servo myServo;

void setup() {
    Particle.function("controlMotor", controlMotor);
    Particle.function("getWindowPosition", getWindowPosition);
    Particle.function("setWindowPosition", setWindowPosition);
    myServo.attach(D1);
    windowOpened = true;
    taskRunning = false; 
}
void loop() {
}

int controlMotor(String command) {
    taskRunning = true; 
    myServo.attach(SERVO_PIN);
    Log.info("Function called with arg: %s", command);
    if(command == "open" && windowOpened == false) {
        Log.info("opening");
        myServo.write(180);
        delay(7000);
        Log.info("Stopping motor after 3 seconds");
        myServo.write(90);
        myServo.detach();
        delay(1000);
        windowOpened = true;
        taskRunning = false; 
        return 1; // Success
    }
    else if (command == "off" && windowOpened == true) {
        myServo.write(0);
        delay(1000);
        myServo.write(90);
        taskRunning = false; 
        return 1;
    }
    else if (command == "close") {
            
        Log.info("closing");
        myServo.write(0);
        delay(7000);
        myServo.write(90);
        myServo.detach();
        delay(1000);
        windowOpened = false;
        taskRunning = false; 
        return 1; // Success
    }
    else {
        Log.warn("Invalid command: %s", command);
        taskRunning = false; 
        return -1; // Invalid command
    }
}

int getWindowPosition(String command) {
    return windowOpened? 1 : 0; // Return 1 if window is open, 0 if closed
}

int setWindowPosition(String opened) {
    if (opened == "true") {
        windowOpened = true;
    }
    else if (opened == "false") {
        windowOpened = false;
    }
    return 1; // Return 1 for success
}
*/