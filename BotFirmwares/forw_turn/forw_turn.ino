#include <AFMotor.h>

// DC motor on M2
AF_DCMotor motorL(3);
AF_DCMotor motorR(4);

void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps
  Serial.println("Motor party!");
//   
//  // turn on motor #2
  motorL.setSpeed(200);
  motorL.run(RELEASE);
//  // turn on motor #2
  motorR.setSpeed(200);
  motorR.run(RELEASE);
}

int i;

// Test the DC motor, stepper and servo ALL AT ONCE!
void loop() {
  motorL.run(FORWARD);
  motorR.run(BACKWARD);
    motorL.setSpeed(200);  
    motorR.setSpeed(200);  
//  Serial.println("Forward!");
    delay(500);

    motorL.run(RELEASE);
    motorR.run(RELEASE);
    delay(1000);
  
    motorL.run(BACKWARD);
    motorR.run(BACKWARD);
      motorL.setSpeed(255);  
      motorR.setSpeed(255);  
    delay(500);
 
    motorL.run(RELEASE);
    motorR.run(RELEASE);
    delay(1000);    

}
