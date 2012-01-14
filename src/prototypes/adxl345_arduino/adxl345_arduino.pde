#include <Wire.h>

#define DEVICE (0x53)  // ADXL345 device address
#define TO_READ (6)    // Num of bytes we are going to read each time (two bytes for each axis)

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
  int regAddress = 0x32;  // First axis-acceleration-data register on the ADXL345
  int x, y, z;
  
  readFrom(DEVICE, regAddress, TO_READ, buff);  // Read the acceleration data from the ADXL345
  
  // Each axis reading comes in 10 bit resolution, ie 2 bytes.  Least Significat Byte first!
  // Thus we are converting both bytes in to one int
  x = (((int)buff[1]) << 8) | buff[0];   
  y = (((int)buff[3]) << 8) | buff[2];
  z = (((int)buff[5]) << 8) | buff[4];
  
  // We send the x y z values as a string to the serial port
  sprintf(str, "%d %d %d", x, y, z);  
  Serial.print(str);
  Serial.print(10, BYTE);
  
  // It appears that delay is needed in order not to clog the port
  delay(200);
}

// Writes val to address register on device
void writeTo(int device, byte address, byte val) {
   Wire.beginTransmission(device);  // Start transmission to device 
   Wire.send(address);              // Send register address
   Wire.send(val);                  // Send value to write
   Wire.endTransmission();
}

// Reads num bytes starting from address register on device in to buff array
void readFrom(int device, byte address, int num, byte buff[]) {
  Wire.beginTransmission(device);   // Start transmission to device 
  Wire.send(address);               // Sends address to read from
  Wire.endTransmission();
  
  Wire.beginTransmission(device);   // Start transmission to device
  Wire.requestFrom(device, num);    // Request 6 bytes from device
  
  int i = 0;
  while (Wire.available()) {        // Device may send less than requested (abnormal) 
    buff[i] = Wire.receive();       // Receive a byte
    i++;
  }
  
  Wire.endTransmission();
}
