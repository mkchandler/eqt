int x, y; 

void setup() {
  Serial.begin(9600);
}

void loop() {
  x = analogRead(2);
  y = analogRead(3);
  
  Serial.print("Rotational rates are x, y: ");
  Serial.print(x, DEC);
  Serial.print(" ");
  Serial.println(y, DEC);
  
  delay(200);
}
