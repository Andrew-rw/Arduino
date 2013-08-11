#include <stdarg.h>
#include <Servo.h> 
// LCD connector;
// 1   2   3   4   5   6   7   8   9   
// GND U+  A0  E   D4  D5  D6  D7  UBL+
// GND 5V  D7  D8  D9  D10 D11 D12 
// initialize the library with the numbers of the interface pins
//LiquidCrystal lcd(12, 11, 5, 4, 3, 2);
//LiquidCrystal lcd(7, 8, 9, 10, 11, 12);
 
const int minAngle = -50;
const int maxAngle = +50
const int angleStep = 1;
const int MAX_IN_BEAM = 3;
 
//void lcdPrint(char *fmt, ... ){
//  char tmp[16]; // resulting string limited to 16 chars
//  va_list args;
//  va_start (args, fmt);
//  vsnprintf(tmp, 128, fmt, args);
//  va_end (args);
//  lcd.print(tmp);
//}
 
void serPrint(char *fmt, ... ){
  char tmp[16]; // resulting string limited to 16 chars
  va_list args;
  va_start (args, fmt);
  vsnprintf(tmp, 128, fmt, args);
  va_end (args);
  Serial.print(tmp);
}
 
// variables to take x number of readings and then average them
// to remove the jitter/noise from the DYP-ME007 sonar readings
const int numReadings = 2; 
 
// setup pins and variables for DYP-ME007 sonar device
int echoPin = 2; // DYP-ME007 echo pin (digital 2)
int initPin = 3; // DYP-ME007 trigger pin (digital 3)
 
unsigned long lastDistance = 0; // variable for storing the distance (cm)
 
Servo myservo;  // create servo object to control a servo 
const int servoPin = 9;
 
int servo = 0;
int servoDir = 1;
 
void setup() {
  pinMode(initPin, OUTPUT); // set init pin 3 as output
  pinMode(echoPin, INPUT); // set echo pin 2 as input
 
  myservo.attach(servoPin);  // attaches the servo on pin 6 to the servo object 
 
  Serial.begin(115200);
 
//  pinMode(servoPin, OUTPUT); 
  myservo.write(90);              // tell servo to go to position in variable 'pos'   
}
 
//void loop(){}

void loop() {
  unsigned long pulseTime;
  float distance[MAX_IN_BEAM];
  unsigned long maxWaitTime = 10000UL;
 
  int found=0;
  for (int i=0; i<MAX_IN_BEAM; i++) {
     digitalWrite(initPin, LOW); 
     delayMicroseconds(2);     
     digitalWrite(initPin, HIGH); // send 10 microsecond pulse
     delayMicroseconds(10); // wait 10 microseconds before turning off
     digitalWrite(initPin, LOW); // stop sending the pulse
 
    pulseTime = pulseIn(echoPin, HIGH, maxWaitTime); // Look for a return pulse, it should be high as the pulse goes low-high-low
    if (pulseTime > 0) {
      distance[found] = microsecondsToCentimeters(pulseTime); 
      found++;
    }
 
    maxWaitTime-= pulseTime;
    if (maxWaitTime <= 0)
      break;
  }
 
  serPrint("L%d", servo);
  for (int i=0; i<found; i++) {
    serPrint(",%d", int(round(distance[i])));
  }
  serPrint(",\r\n");
 
  myservo.write(85-servo);              // tell servo to go to position in variable 'pos'   
  servo+= servoDir;
  if (servo >= maxAngle) { 
    servoDir = -angleStep;
  } else
  if (servo <= minAngle) { 
    servoDir = +angleStep;
  }
  delay(100);
}

long microsecondsToCentimeters(long microseconds) { 
  return microseconds / 29 / 2; 
} 
