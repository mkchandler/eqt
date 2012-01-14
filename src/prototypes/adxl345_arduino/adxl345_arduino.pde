#include <Wire.h>

#define DEVICE (0x53)  // ADXL345 device address
#define TO_READ (6)    // Number of bytes we are going to read each time (two bytes for each axis)

byte buff[TO_READ] ;   // 6 bytes buffer for saving data read from the device
char str[512];         // String buffer to transform data before sending it to the serial port

void setup() {
  Wire.begin();        // Join i2c bus (address optional for master)
  Serial.begin(9600);  // Start serial for output
  
  // Turning on the ADXL345
  writeTo(DEVICE, 0x2D, 0);      
  writeTo(DEVICE, 0x2D, 16);
  writeTo(DEVICE, 0x2D, 8);
}

void loop() {
  int register_address = 0x32;
  int x, y, z;
  
  readFrom(DEVICE, register_address, TO_READ, buff);
  
  // Each axis reading comes in 10 bit resolution, ie 2 bytes (least significat byte first)
  // Thus we are converting both bytes in to one int
  x = (((int)buff[1]) << 8) | buff[0];   
  y = (((int)buff[3]) << 8) | buff[2];
  z = (((int)buff[5]) << 8) | buff[4];
  
  sprintf(str, "%d %d %d", x, y, z);  
  Serial.print(str);
  Serial.print(10, BYTE);

  delay(200);
}

void writeTo(int device, byte address, byte val) {
   Wire.beginTransmission(device);
   Wire.send(address);
   Wire.send(val);
   Wire.endTransmission();
}

void readFrom(int device, byte address, int num, byte buff[]) {
  Wire.beginTransmission(device);
  Wire.send(address);
  Wire.endTransmission();
  
  Wire.beginTransmission(device);
  Wire.requestFrom(device, num);
  
  int i = 0;
  while (Wire.available()) {
    buff[i] = Wire.receive();
    i++;
  }
  
  Wire.endTransmission();
}
