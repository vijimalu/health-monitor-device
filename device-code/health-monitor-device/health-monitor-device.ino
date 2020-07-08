/*
 * Project Name: Health Monitoring System
 * Micro-controller: Arduino UNO
 * Created On: 30 May 2020
 * Created by: Vijitha V Nair
 */
 
// GPS module library
#include <TinyGPS++.h>
#include <SoftwareSerial.h>

// Pulse sensor library
#define USE_ARDUINO_INTERRUPTS true    // Set-up low-level interrupts for most acurate BPM math.
#include <PulseSensorPlayground.h>     // Includes the PulseSensorPlayground Library.

// OLED library
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 32 // OLED display height, in pixels
#define OLED_RESET     4 // Reset pin # (or -1 if sharing Arduino reset pin)

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

static const int RXPin = 13, TXPin = 12;
static const uint32_t GPSBaud = 4800;
static const uint32_t serialPort = 115200;
static const uint32_t bluetoothSerialRate = 9600;

int heartBeatSensor = A0;
int Threshold = 550;

TinyGPSPlus gps; // The TinyGPS++ object
SoftwareSerial ss(RXPin, TXPin); // The serial connection to the GPS device
PulseSensorPlayground pulseSensor; // Creates an instance of the PulseSensorPlayground object called "pulseSensor"
SoftwareSerial bluetoothSerial(11, 10); // RX, TX


/* For GPS */
float latitude , longitude;
int year , month , date, hour , minute , second;
String date_str , time_str , lat_str , lng_str;
int heartBeat;
float bodyTemp = 36.6;

void setup() {
  pinMode(3,INPUT_PULLUP);
  Serial.begin(serialPort);
  Serial.println("Health Monitoring System");
  Serial.println("Project by Vijitha V Nair");
  ss.begin(GPSBaud);
  if (millis() > 5000 && gps.charsProcessed() < 10) {
    Serial.println(F("No GPS detected: check wiring."));
    while(true);
  }
  Serial.println("GPS module initialisation complete...");

  pulseSensor.analogInput(heartBeatSensor);
  pulseSensor.blinkOnPulse(LED_BUILTIN);
  pulseSensor.setThreshold(Threshold);
  if (pulseSensor.begin()) {
    Serial.println("Heat beat sensor initialisation complete...");  //This prints one time at Arduino power-up,  or on Arduino reset.  
  }

  bluetoothSerial.begin(bluetoothSerialRate);

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

void loop() {
  // This sketch displays information every time a new sentence is correctly encoded.
  while (ss.available() > 0)
  
  if (gps.encode(ss.read()))
    if (gps.location.isValid()) {
      latitude = gps.location.lat();
      lat_str = String(latitude , 6);
      longitude = gps.location.lng();
      lng_str = String(longitude , 6);
    }
    if (gps.date.isValid()) {
      date_str = "";
      date = gps.date.day();
      month = gps.date.month();
      year = gps.date.year();
  
      if (date < 10)
        date_str = '0';
      date_str += String(date);
  
      date_str += "/";
  
      if (month < 10)
        date_str += '0';
      date_str += String(month);
  
      date_str += "/";
  
      if (year < 10)
        date_str += '0';
      date_str += String(year);
    }
  
    if (gps.time.isValid()) {
      time_str = "";
      hour = gps.time.hour();
      minute = gps.time.minute();
      second = gps.time.second();
  
      if (hour < 10)
        time_str = '0';
      time_str += String(hour);
  
      time_str += ":";
  
      if (minute < 10)
        time_str += '0';
      time_str += String(minute);
  
      time_str += ":";
  
      if (second < 10)
        time_str += '0';
      time_str += String(second);
    }
    
  heartBeat=pulseSensor.getBeatsPerMinute();

  if (lat_str == "") {
    lat_str = "loading";
  }
  if (lng_str == "") {
    lng_str = "loading";
  }
  if (date_str == "") {
    date_str = "loading";
  }
  if (time_str == "") {
    time_str = "loading";
  }

  display.clearDisplay();
  display.setTextSize(2);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0,0);
  display.println(date_str);
  display.setCursor(0,18);
  display.println(heartBeat);
  display.display();

  bluetoothSerial.write(latitude);
  bluetoothSerial.write(",");
  bluetoothSerial.write(longitude);
  bluetoothSerial.write(",");
  bluetoothSerial.write(heartBeat);
  bluetoothSerial.write(",");
  bluetoothSerial.write(bodyTemp);
  bluetoothSerial.write(",");
  bluetoothSerial.write(digitalRead(3));

  Serial.println("----------------------------------------");
  Serial.println("Values:-");
  Serial.print("Lattitude: ");Serial.println(lat_str);
  Serial.print("Longitude: ");Serial.println(lng_str);
  Serial.print("Date: ");Serial.println(date_str);
  Serial.print("Time: ");Serial.println(time_str);
  Serial.print("Heatbeat: ");Serial.println(heartBeat);
  Serial.print("Body Temperature: ");Serial.println(bodyTemp);
   Serial.print("Button status: ");Serial.println(digitalRead(3));
  Serial.println("----------------------------------------");

  delay(500);
}
