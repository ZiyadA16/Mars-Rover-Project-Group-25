#include <Arduino.h>
#include <SPI.h>
#include <Wire.h>
#include <MFRC522.h>
#include <WiFi.h>
#include <string.h>

#define SCK 18
#define MISO 19
#define MOSI 23
#define CS 5

#define RST_PIN 4
#define SS_PIN 2

MFRC522 mfrc522(SS_PIN, RST_PIN);

#define LED 2

IPAddress local_IP(192,168,1,184);
IPAddress gateway(192,168,1,1);
IPAddress subnet(255,255,0,0);
IPAddress primaryDNS(8,8,8,8);
IPAddress secondaryDNS(8,8,4,4);

const int buttonPin1 = 34;
int buttonState, B1_state;
int lastButtonState = LOW;
unsigned long lastDebounceTime = 0;
unsigned long debounceDelay = 40;
char* ssid;
char* password;
String idcard;

void initWiFi(){
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi ..");
  while(WiFi.status() != WL_CONNECTED){
    Serial.print('.');

    delay(1000);
  }
  Serial.println(WiFi.localIP());
}

int read_state_Button(int buttonPin)
{
  buttonState = 0;
  int reading = digitalRead(buttonPin);
  if (reading != lastButtonState)
  {
    lastDebounceTime = millis();  
  }
  delay(debounceDelay + 1); 
  if ((millis() - lastDebounceTime) > debounceDelay)
  {
    if(reading != buttonState)
    {
      buttonState= reading;
    }
  }
  lastButtonState = reading;
  return buttonState;
}

void setup()
{
  Serial.begin(115200);
  pinMode(buttonPin1,INPUT);
  SPI.begin();
  mfrc522.PCD_Init(); 
  if (!WiFi.config(local_IP,gateway,subnet,primaryDNS,secondaryDNS)){
  Serial.println("STA Failed to configure");}
}
void loop()
{
  B1_state = read_state_Button(buttonPin1);
  if(B1_state == HIGH){
    Serial.println("Button pushed");
  }
   if(mfrc522.PICC_IsNewCardPresent())
 {
   if(mfrc522.PICC_ReadCardSerial())
   {
     idcard = "";
     for (byte i = 0; i < mfrc522.uid.size; i++){
       idcard += (mfrc522.uid.uidByte[i] < 0x10 ? "0" : "") + String(mfrc522.uid.uidByte[i],HEX);
     }
     Serial.println("tag rfid :" + idcard);
     mfrc522.PICC_HaltA();
     mfrc522.PCD_StopCrypto1();
   }
 }

 unsigned long currentMillis = millis();
 unsigned long previousMillis = 0;
 unsigned long interval = 30000;
  if((WiFi.status()!= WL_CONNECTED) && (currentMillis - previousMillis >= interval)){
   Serial.print(millis());
   Serial.println("Reconnecting to WiFi...");
   WiFi.disconnect();
   WiFi.reconnect();
   previousMillis = currentMillis;
 }
}