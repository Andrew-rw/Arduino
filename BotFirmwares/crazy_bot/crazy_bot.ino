#include <AFMotor.h>

// DC motor on M2
AF_DCMotor motorL(3);
AF_DCMotor motorR(4);
long randNumb;

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

// Test the DC motor, stepper and servo ALL AT ONCE!
void loop() {
  randNumb = random(0, 4);

  switch (randNumb) {
    case 0:
      forward();
      break;
    case 1:
      backward();
      break;
    case 2:
      left();
      break;
    case 3:
      right();
      break;
  }
  rel();
  delay(1000);    
}

void backward(){
  motorL.run(FORWARD);
  motorR.run(BACKWARD);
  motorL.setSpeed(200);  
  motorR.setSpeed(200);  
//  Serial.println("Forward!");
  delay(500);  
}

void left(){
  motorL.run(BACKWARD);
  motorR.run(BACKWARD);
  motorL.setSpeed(255);  
  motorR.setSpeed(255);  
//  Serial.println("Left!");
  delay(500);
}

void right(){
  motorL.run(FORWARD);
  motorR.run(FORWARD);
  motorL.setSpeed(255);  
  motorR.setSpeed(255);  
//  Serial.println("Right!");
  delay(500);
}

void forward(){
  motorL.run(BACKWARD);
  motorR.run(FORWARD);
  motorL.setSpeed(200);  
  motorR.setSpeed(200);  
//  Serial.println("Forward!");
  delay(500);  
}

void rel(){
  motorL.run(RELEASE);
  motorR.run(RELEASE);
}

