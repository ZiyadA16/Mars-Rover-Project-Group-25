// INA219 Current Sensor with OLED Display for Arduino Uno
//
// This sketch was modified from the Adafruit INA219 library example
//
// Gadget Reboot
//
// Required Libraries
// https://github.com/adafruit/Adafruit_INA219
// https://github.com/adafruit/Adafruit_SSD1306

#include <Wire.h>
#include <Adafruit_INA219.h>
#include <Adafruit_SSD1306.h>
Adafruit_INA219 ina219;

float current_mA = 0;



void setup() {

  Serial.begin(9600);
  // initialize ina219 with default measurement range of 32V, 2A
  ina219.begin();

  // ina219.setCalibration_32V_2A();    // set measurement range to 32V, 2A  (do not exceed 26V!)
  // ina219.setCalibration_32V_1A();    // set measurement range to 32V, 1A  (do not exceed 26V!)
  // ina219.setCalibration_16V_400mA(); // set measurement range to 16V, 400mA

}

void loop() {

  // read data from ina219

  current_mA = ina219.getCurrent_mA();




  Serial.println("Current = " +String(current_mA,3) + " mA");


}
