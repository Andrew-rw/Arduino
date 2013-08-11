#include <AFMotor.h>

AF_DCMotor motorL(3);
AF_DCMotor motorR(4);
long randNumb;

void setup() {
  motorL.run(RELEASE);
  motorR.run(RELEASE);
}

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
  motorL.setSpeed(200);  
  motorR.setSpeed(200);  
  motorL.run(FORWARD);
  motorR.run(BACKWARD);
//  Serial.println("Forward!");
  delay(500);  
}

void left(){
  motorL.setSpeed(255);  
  motorR.setSpeed(255);  
  motorL.run(BACKWARD);
  motorR.run(BACKWARD);
//  Serial.println("Left!");
  delay(250);
}

void right(){
  motorL.setSpeed(255);  
  motorR.setSpeed(255);  
  motorL.run(FORWARD);
  motorR.run(FORWARD);
//  Serial.println("Right!");
  delay(250);
}

void forward(){
  motorL.setSpeed(200);  
  motorR.setSpeed(200);  
  motorL.run(BACKWARD);
  motorR.run(FORWARD);
//  Serial.println("Forward!");
  delay(500);  
}

void rel(){
  motorL.run(RELEASE);
  motorR.run(RELEASE);
}

