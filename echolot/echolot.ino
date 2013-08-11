

// include the library code:
#include <LiquidCrystal.h>

// initialize the library with the numbers of the interface pins
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

String inputString = "";         // a string to hold incoming data
boolean stringComplete = false;  // whether the string is complete

int pingPin = 10; 
int inPin = 9;
int counter = 0;
long cm = 0;

void setup() {

  Serial.begin(9600);
  // reserve 200 bytes for the inputString:
  inputString.reserve(200);
}

void loop() {

long duration; 
  pinMode(pingPin, OUTPUT); 
  digitalWrite(pingPin, LOW); 
  delayMicroseconds(2); 
  digitalWrite(pingPin, HIGH); 
  delayMicroseconds(10); 
  digitalWrite(pingPin, LOW);
  
  pinMode(inPin, INPUT); 
  duration = pulseIn(inPin, HIGH);

  cm += microsecondsToCentimeters(duration); 
  
  if(counter==3){
    lcd.clear(); 
    lcd.setCursor(5, 0); 
    lcd.print(cm/3); 
    lcd.print(" cm");
    counter=0;
    cm=0;
  }else{
    counter++;
  }
  delay(100); 
}

long microsecondsToCentimeters(long microseconds) { 
  return microseconds / 29 / 2; 
} 
