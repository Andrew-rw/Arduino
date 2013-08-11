void setup()
{
  Serial.begin(9600);
}

void loop()
{
  static unsigned long millis_at_last_display = 0;

  if (millis() - millis_at_last_display >= 1000)
  {
    Serial.println(2000);
    millis_at_last_display = millis();
  }  
  Serial.println(map(analogRead(0),160,870,-1000,1000));
  
  //delay(500);
}
