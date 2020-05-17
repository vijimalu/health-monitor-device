/*
 * Project Name: Health Monitoring System
 * Micro-controller: Arduino UNO
 * Created On: 17 May 2020
 * Created by: Vijitha V Nair
 */

#define USE_ARDUINO_INTERRUPTS true    // Set-up low-level interrupts for most acurate BPM math.
#include <PulseSensorPlayground.h>     // Includes the PulseSensorPlayground Library.

PulseSensorPlayground pulseSensor;  // Creates an instance of the PulseSensorPlayground object called "pulseSensor"

#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 32 // OLED display height, in pixels

// Declaration for an SSD1306 display connected to I2C (SDA, SCL pins)
#define OLED_RESET     4 // Reset pin # (or -1 if sharing Arduino reset pin)
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

int heartBeatSensor = A0;
int Threshold = 550;

// Function declaration
void serialMonitorInitialisation();
void heartBeatSensorInitialisation();
void displayMonitorInitialDisplay();

int getHeartBeat();

void setup() {
  serialMonitorInitialisation();
  displayMonitorInitialDisplay();
  heartBeatSensorInitialisation();
}

void loop() {
  Serial.println(getHeartBeat());
  delay(1000);
}

/**************************************************************
The following function will be used for initialising sensor
**************************************************************/
// Function to initialise serial monitor
void serialMonitorInitialisation() {
  Serial.begin(9600);
  Serial.println("**************************************");
  Serial.println("Project Name: Health Monitoring System");
  Serial.println("Created By: Vijitha V Nair (LTVE17MCA071) <vijithaprabha321@gmail.com>");
  Serial.println("Created on: 17 May 2020");
  Serial.println("**************************************");
  Serial.println("Serial monitor initialisation complete...");
}

void displayMonitorInitialDisplay() {
  if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) { // Address 0x3C for 128x32
    Serial.println(F("SSD1306 allocation failed"));
    for(;;);
  }

  display.clearDisplay();
  display.setTextSize(2);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(25,0);
  display.println(F("Health"));
  display.setCursor(23,18);
  display.println(F("Monitor"));
  display.display();
  delay(1000);

  display.clearDisplay();
  display.setTextSize(2);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(4,0);
  display.println(F("By,"));
  display.setCursor(10,18);
  display.println(F("Vijitha V"));
  display.display();
  delay(2000);
}

// Heart beat sensor initilaisation
void heartBeatSensorInitialisation() {
  pulseSensor.analogInput(heartBeatSensor);
  pulseSensor.blinkOnPulse(LED_BUILTIN);
  pulseSensor.setThreshold(Threshold);
  if (pulseSensor.begin()) {
    Serial.println("Heat beat sensor initialisation complete....");  //This prints one time at Arduino power-up,  or on Arduino reset.  
  }
}

/*****************************************************************
The following function will be used for get values from sensor
*****************************************************************/

// Function to get heart beat from sensor
int getHeartBeat() {
  int heartBeat = pulseSensor.getBeatsPerMinute();
  if (pulseSensor.sawStartOfBeat()) { 
   return heartBeat;
  }
}
