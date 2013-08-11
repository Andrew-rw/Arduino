#include <AFMotor.h>

// DC motor on M2
AF_DCMotor motorL(3);
AF_DCMotor motorR(4);

void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps
  Serial.println("Motor party!");
//   
//  // turn on motor #2
  motorL.setSpeed(255);
  motorL.run(RELEASE);
//  // turn on motor #2
  motorR.setSpeed(255);
  motorR.run(RELEASE);
}

int i;

// Test the DC motor, stepper and servo ALL AT ONCE!
void loop() {
  motorL.run(FORWARD);
  motorR.run(BACKWARD);
  for (i=100; i<255; i++) {
    motorL.setSpeed(i);  
    motorR.setSpeed(i);  
//  Serial.println("Forward!");
    delay(10);
 }
 
  for (i=255; i!=100; i--) {
    motorL.setSpeed(i);  
    motorR.setSpeed(i);  
    delay(10);
 }
  motorL.run(RELEASE);
  motorR.run(RELEASE);
  delay(1000);
  
  motorL.run(BACKWARD);
  motorR.run(FORWARD);
  for (i=100; i<255; i++) {
    motorL.setSpeed(i);  
    motorR.setSpeed(i);  
//  Serial.println("Backward!");
    delay(10);
  }
 
  for (i=255; i!=100; i--) {
    motorL.setSpeed(i);  
    motorR.setSpeed(i);  
    delay(10);
 }

  motorL.run(RELEASE);
  motorR.run(RELEASE);
  delay(1000);    

}
