 /*
 * Program written by Yue Zhu (yue.zhu18@imperial.ac.uk) in July 2020.
 * pin6 is PWM output at 62.5kHz.
 * duty-cycle saturation is set as 2% - 98%
 * Control frequency is set as 1.25kHz. 
*/

#include <SPI.h>
#include <SD.h>
#include <Wire.h>
#include <INA219_WE.h>

INA219_WE ina219; // this is the instantiation of the library for the current sensor

Sd2Card card;
SdVolume volume;
SdFile root;

float closed_loop; // Duty Cycles
float vb,iL,current_mA, va; // Measurement Variables
unsigned int sensorValue0,sensorValue3;  // ADC sample values declaration
float ep = 0; //internal signals
float Ts=0.0008; //1.25 kHz control frequency. It's better to design the control period as integral multiple of switching period.
int loopMaxValue = 500;
float kpp=0.078,kip=1.5,kdp=0; // power pid.
float u0p,u1p,delta_up,e0p,e1p,e2p; // Internal values for the power controller

float current_limit = 1.0;
float high_voltage_limit = 5.2;
float low_voltage_limit = 4.5; // Voltage limits

boolean Boost_mode = 0;
boolean CL_mode = 1;

const int chipSelect = 10; //hardwired chip select for the SD card
String dataString;

unsigned int loopTrigger;
unsigned int com_count=0;   // a variables to count the interrupts. Used for program debugging.

int loopCount = 0;

void setup() {
  Wire.begin(); // We need this for the i2c comms for the current sensor
  ina219.init(); // this initiates the current sensor
  Wire.setClock(700000); // set the comms speed for i2c

   
  //Check for the SD Card
  Serial.begin(9600);
  Serial.println("\nInitializing SD card...");
  if (!SD.begin(chipSelect)) {
    Serial.println("* is a card inserted?");
    while (true) {} //It will stick here FOREVER if no SD is in on boot
  } else {
    Serial.println("Wiring is correct and a card is present.");
  }

  if (SD.exists("PVB4bA.csv")) { // Wipe the datalog when starting
    SD.remove("PVB4bA.csv");
  }
    
  //Basic pin setups
  
  noInterrupts(); //disable all interrupts
  pinMode(13, OUTPUT);  //Pin13 is used to time the loops of the controller
  pinMode(3, INPUT_PULLUP); //Pin3 is the input from the Buck/Boost switch
  pinMode(2, INPUT_PULLUP); // Pin 2 is the input from the CL/OL switch
  analogReference(EXTERNAL); // We are using an external analogue reference for the ADC

  pinMode(8, OUTPUT);
  // TimerA0 initialization for control-loop interrupt.
  
  TCA0.SINGLE.PER = 999; //
  TCA0.SINGLE.CMP1 = 999; //
  TCA0.SINGLE.CTRLA = TCA_SINGLE_CLKSEL_DIV16_gc | TCA_SINGLE_ENABLE_bm; //16 prescaler, 1M.
  TCA0.SINGLE.INTCTRL = TCA_SINGLE_CMP1_bm; 

  // TimerB0 initialization for PWM output
  
  pinMode(6, OUTPUT);
  TCB0.CTRLA=TCB_CLKSEL_CLKDIV1_gc | TCB_ENABLE_bm; //62.5kHz
  analogWrite(6,120); 
  

  interrupts();  //enable interrupts.

}


// This is a PID controller for the power

float pidp(float pid_input){
  float e_integration;
  e0p = pid_input;
  e_integration=e0p;
  //anti-windup
  if(u1p >= 4){
    e_integration = 0;
  } else if (u1p <= 0) {
    e_integration = 0;
  }

  delta_up = kpp*(e0p-e1p) + kip*Ts*e_integration + kdp/Ts*(e0p-2*e1p+e2p);//incremental PID programming avoids integrations.
  u0p = u1p + delta_up;  //this time's control output
  
  //output limitation
  u0p = saturation(u0p,5.1/va,4.6/va);
  if(iL > 2){
      u0p=u0p-0.04;
    }
  else if(iL<0){
      u0p=u0p+0.04;
    }

  if(vb > 5.1){
      u0p=u0p -0.04;
    }
  else if(va<4.6){
      u0p=u0p+0.04;
    }
  u1p = u0p; //update last time's control output
  e2p = e1p; //update last last time's error
  e1p = e0p; // update last time's error
  return u0p;
}

float saturation( float sat_input, float uplim, float lowlim){ // Saturatio function
  if (sat_input > uplim) sat_input=uplim;
  else if (sat_input < lowlim ) sat_input=lowlim;
  else;
  return sat_input;
}

void pwm_modulate(float pwm_input){ // PWM function
  analogWrite(6,(int)(255-pwm_input*255)); 
}

 void loop() {
  if(loopTrigger) { // This loop is triggered, it wont run unless there is an interrupt
    
    digitalWrite(13, HIGH);   // set pin 13. Pin13 shows the time consumed by each control cycle. It's used for debugging.
    
    // Sample all of the measurements and check which control mode we are in
    sampling();

    // The closed loop path has a voltage controller cascaded with a current controller. The voltage controller
    // creates a current demand based upon the voltage error. This demand is saturated to give current limiting.
    // The current loop then gives a duty cycle demand based upon the error between demanded current and measured
    // current

    ep = 10.4 - va*iL;          
          
    closed_loop = pidp(ep); // power PID controller
    closed_loop=saturation(closed_loop,0.999,0.001);  //duty_cycle saturation
    pwm_modulate(closed_loop); //pwm modulation

    digitalWrite(13, LOW);   // reset pin13.
    loopCount++;
    loopTrigger = 0;
  }

  
  if(loopCount == loopMaxValue){
    //Relay limits
     if (vb > high_voltage_limit || vb < low_voltage_limit || iL > current_limit){
        digitalWrite(8, HIGH);
     }
     else{
        digitalWrite(8, LOW);
     }
      
     
      
    digitalWrite(4, !digitalRead(4));

    // Max power is 5.2*2 = 10.4 W
    
    dataString = String(iL, 5) + "," + String(va, 4) + "," + String(vb, 4); //build a datastring for the CSV file
    Serial.println(dataString);
    File dataFile = SD.open("PVB4bA.csv", FILE_WRITE); // open our CSV file
    if (dataFile){ //If we succeeded (usually this fails if the SD card is out)
      dataFile.println(dataString); // print the data
    } else {
      Serial.println("File not open"); //otherwise print an error
    }
    dataFile.close(); // close the file       

    
    loopCount = 0;
    }
}


// Timer A CMP1 interrupt. Every 800us the program enters this interrupt. 
// This, clears the incoming interrupt flag and triggers the main loop.

ISR(TCA0_CMP1_vect){
  TCA0.SINGLE.INTFLAGS |= TCA_SINGLE_CMP1_bm; //clear interrupt flag
  loopTrigger = 1;
}


// This subroutine processes all of the analogue samples, creating the required values for the main loop

void sampling(){

  // Make the initial sampling operations for the circuit measurements
  sensorValue0 = analogRead(A0); //sample Vb
  sensorValue3 = analogRead(A3); //sample Vpd
  current_mA = ina219.getCurrent_mA(); // sample the inductor current (via the sensor chip)

  // Process the values so they are a bit more usable/readable
  // The analogRead process gives a value between 0 and 1023 
  // representing a voltage between 0 and the analogue reference which is 4.096V
  
  vb = sensorValue0 * (4.096 / 1023.0) * 1.625; // Convert the Vb sensor reading to volts
  
  va = 2.697*sensorValue3 * (4.096 / 1023.0); // Convert the Vpd sensor reading to volts

  // The inductor current is in mA from the sensor so we need to convert to amps.
  // We want to treat it as an input current in the Boost, so its also inverted
  // For open loop control the duty cycle reference is calculated from the sensor
  // differently from the Vref, this time scaled between zero and 1.
  // The boost duty cycle needs to be saturated with a 0.33 minimum to prevent high output voltages
  
  iL = current_mA/1000.0;
    
}




/*end of the program.*/
