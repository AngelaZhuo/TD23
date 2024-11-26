
#include <SPI.h>
// pins used for perfumes, animalboxes, TTL outputs (initialize as output, set low)

// add new TTL output pins for laser etc
const int outPins[] = {35, 37, 39, 41, 43, 45, 47, 49, 51, 53,
                 22, 24, 26, 28, 30, 32, 34, 36, 38, 40,
                 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
                };

// define pins used for different odors
 int odor_pin_map[106] = {};


// Logic
boolean odorON, OdorToDo, OdorDelivered;

uint8_t i;

// default parameters
uint16_t odor_lat = 1;
int Preloading = 3000;
uint16_t  ITI = Preloading + 1;

int odor_valve_pin = 53;
int mix_valve_pin = 11;
int final_valve_pin = 12;

int fv_to_intan = 22;
int led_to_intan = 24;
int led_trigger = 32;
//int ambient_trigger = 34;
int puff_trigger = 30; // check
int red_laser_trigger = 30;
int blue_laser_trigger = 34;
int current_laser_color = 30;
int puff_to_intan = 26;
//int laser_trigger = 1234; //check
int laser_ttl = 26; //check
int trial_on_ttl = 28; // to intan

// Timing
unsigned long startTime = 0;
unsigned long currentTime, TrialStartTime, TimerStart, DropOnTime, OdorOnTime, FirstLickTime, OdorOffTime;
unsigned long  MomentaryTime;


// parameters that get sent by superflex2000.mat
uint16_t  laser_delay;
uint16_t  laser_pattern = 0; //default
uint16_t laser_pulselength;
uint16_t laser_duration;
uint16_t laser_frequency;
uint16_t laser_color;
uint16_t laser_number_of_pulses;
uint16_t  odor_dur;
int16_t   odor_num;
uint16_t reward_active;
uint16_t drop_or_not;
uint16_t lick_delay, reward_delay, discovery_help, lick_window;
uint16_t reward_size = 80; //default
uint16_t lick_threshold;


// Misc and defaults
int state = 0;
int reward = 5;               //Report=4: Miss 1: Hit 2: False Alarm 3:Correct Rejection 5:default
int LaserTTL;

// serial comm



char buffer[128];
uint8_t idx = 0;
char *argv[40];
int arg1, arg2, arg3;
uint8_t txbuffer[64];

int currentstate;

void parse(char *line, char **argv, uint8_t maxArgs) {
  uint8_t argCount = 0;
  while (*line != '\0') {       // if not the end of line .......
    while (*line == ',' || *line == ' ' || *line == '\t' || *line == '\n')
      *line++ = '\0';     // replace commas and white spaces with 0
    *argv++ = line;          // save the argument position
    argCount++;
    if (argCount == maxArgs - 1)
      break;
    while (*line != '\0' && *line != ',' && *line != ' ' &&
           *line != '\t' && *line != '\n')
      line++;             // skip the argument until ...
  }
  *argv = '\0';                 // mark the end of argument list
}

void OdorFun() {

  // turn on odor if applicable
  if (!odorON && OdorToDo && !OdorDelivered) {
    if  (currentTime - TrialStartTime > odor_lat) {
      //Serial.println("odor on!");
      //delay(500);
      digitalWrite(final_valve_pin, HIGH);
      digitalWrite(fv_to_intan, HIGH);
      digitalWrite(13, HIGH);
      if (odor_num<13){
        digitalWrite(mix_valve_pin, HIGH);
      }

      odorON = true;
      OdorOnTime = millis();
    }
  }

  // turn off odor

  if (!OdorDelivered && odorON && OdorToDo) {
    if  ((currentTime - TrialStartTime) > (odor_lat + odor_dur)) {
     // Serial.println("odor off!");
      // delay(500);

      digitalWrite(13, LOW);
      digitalWrite(fv_to_intan, LOW);
      digitalWrite(final_valve_pin, LOW);

      delay(50);
      
      digitalWrite(mix_valve_pin, LOW);
      digitalWrite(odor_num, LOW);
      digitalWrite(odor_valve_pin, LOW);

      odorON = false;
      OdorDelivered = true;

    }
  }

}

void setup() {

  pinMode(13, OUTPUT);
  digitalWrite(13, LOW);
  // set pins used to output and initialize in off-state

  for ( i = 2; i < 60; ++i ) {

    pinMode(i, OUTPUT);
    delay(20);
    digitalWrite(i, LOW);
        delay(20);
  }




  // initialize SPI
  // PC communication
  Serial.begin(9600);
  delay(50);
  Serial.println(">System is ready");


}

void loop() {

  switch (state) {

    case 0:
      uint8_t c;
      if (Serial.available() > 0) { // PC communication

        c = Serial.read();
        if (c == '\r') {
          buffer[idx] = 0;
          //Serial.println();
          parse((char*)buffer, argv, sizeof(argv));
          delay(10);
          if (strcmp(argv[0], "trialParams") == 0 | strcmp(argv[0], "o") == 0) {

            odor_num   = (uint16_t)atoi(argv[1]);
            odor_dur   = (uint16_t)atoi(argv[2]);

    //    Serial.println(odor_num);
     //   Serial.println(odor_dur);
    //    delay(1000);
        
            odorON = false;
            OdorDelivered = false;

            if (odor_num > 0) {
              OdorToDo = true;
            }
            else {
              OdorToDo = false;
            }

            startTime = millis();
            state = 1;

          }
          
          if (strcmp(argv[0], "led") == 0) {

            digitalWrite(led_trigger, HIGH);
            digitalWrite(led_to_intan, HIGH);
            delay(1000);
            digitalWrite(led_trigger, LOW);
            digitalWrite(led_to_intan, LOW);
         
          }     

          if (strcmp(argv[0], "laser_pattern_2") == 0) {
            for (int xi=0; xi < 10; xi++){
              digitalWrite(trial_on_ttl, HIGH); 
              digitalWrite(laser_ttl, HIGH);
              digitalWrite(red_laser_trigger,HIGH);
              delayMicroseconds(5000);
              digitalWrite(laser_ttl, LOW);
              digitalWrite(red_laser_trigger,LOW);
              digitalWrite(trial_on_ttl, LOW);
              delay(195);
            }
          }
          
          if (strcmp(argv[0], "laser_pattern_3") == 0) {
            for (int xi=0; xi < 10; xi++){
              digitalWrite(trial_on_ttl, HIGH); 
              digitalWrite(laser_ttl, HIGH);
              digitalWrite(red_laser_trigger,HIGH);
              delayMicroseconds(5000);
              digitalWrite(laser_ttl, LOW);
              digitalWrite(red_laser_trigger,LOW);
              digitalWrite(trial_on_ttl, LOW);
              delay(95);
            }
          }
          
          if (strcmp(argv[0], "single_pulse_excitation") == 0) {
            digitalWrite(trial_on_ttl, HIGH); 
            digitalWrite(laser_ttl, HIGH);
            digitalWrite(red_laser_trigger,HIGH);
            delay(5);
            digitalWrite(laser_ttl, LOW);
            digitalWrite(red_laser_trigger,LOW);
            digitalWrite(trial_on_ttl, LOW);
          }

          
          
          if (strcmp(argv[0], "burst_excitation") == 0) {
            digitalWrite(trial_on_ttl, HIGH);
            for (int i=0; i<6; i++){
              //digitalWrite(laser_trigger, HIGH);
              digitalWrite(laser_ttl, HIGH);
              digitalWrite(red_laser_trigger,HIGH);
              delay(5);
              digitalWrite(laser_ttl, LOW);
              digitalWrite(red_laser_trigger,LOW);
              delay(20);
            }
            digitalWrite(trial_on_ttl, LOW);
          }

          if (strcmp(argv[0], "slow_excitation") == 0) {

            digitalWrite(trial_on_ttl, HIGH);
            for (int i=0; i<6; i++){
              //digitalWrite(laser_trigger, HIGH);
              digitalWrite(laser_ttl, HIGH);
              digitalWrite(red_laser_trigger,HIGH);
              delay(5);
              digitalWrite(laser_ttl, LOW);
              digitalWrite(red_laser_trigger,LOW);
              delay(328);
            }
            digitalWrite(trial_on_ttl, LOW);
          }

          if (strcmp(argv[0], "long_inhibition") == 0) {
            digitalWrite(laser_ttl, HIGH);
            digitalWrite(trial_on_ttl, HIGH);
            digitalWrite(blue_laser_trigger,HIGH);
            delay(2000);
            digitalWrite(laser_ttl, LOW);
            digitalWrite(trial_on_ttl, LOW);
            digitalWrite(blue_laser_trigger,LOW);
          }

          if (strcmp(argv[0], "long_inhibition_+_burst_excitation") == 0) {
            digitalWrite(trial_on_ttl, HIGH);
            digitalWrite(blue_laser_trigger,HIGH);
            delay(1000);
            laser_pulselength = 5;
            for (int i=0; i<6; i++){
              digitalWrite(laser_ttl, HIGH);
              digitalWrite(red_laser_trigger,HIGH);
              delay(laser_pulselength);
              digitalWrite(laser_ttl, LOW);
              digitalWrite(red_laser_trigger,LOW);
              delay(20);
            }
            delay(850);
            digitalWrite(laser_ttl, LOW);
            digitalWrite(trial_on_ttl, LOW);
            digitalWrite(blue_laser_trigger,LOW);
          }
          
          idx = 0;
        }
        else if (((c == '\b') || (c == 0x7f)) && (idx > 0)) {
          idx--;
          // Serial.write(c);
          //Serial.print(" ");
          //Serial.write(c);
        }
        else if ((c >= ' ') && (idx < sizeof(buffer) - 1)) {
          buffer[idx++] = c;
          //Serial.write(c);
        }
      }
      break;


    //activation of odor valve $Preloading msecs before ITI ends
    case 1:

  //  Serial.println("case 1");
      currentTime = millis();
      if  (currentTime - startTime > ITI - Preloading) {

    //    Serial.print("Odor valve is ON  - ");
      //  Serial.println(currentTime-startTime);
        if (odor_num) {

          if (odor_num > 11) { // if vial: switch off normally open last valve
            digitalWrite(odor_valve_pin, HIGH);
          }
            else if (odor_num < 13) {
              digitalWrite(mix_valve_pin, HIGH);
            }
          delay(60);
  
          digitalWrite(odor_num, HIGH);
          digitalWrite(trial_on_ttl, HIGH);
  

        }
        state = 2;
      }
      break;




    // wait ITI
    case 2:
      currentTime = millis();
      if  (currentTime - startTime > ITI) {
       // Serial.print("Waiting 2 more seconds - ");
      //  Serial.println(currentTime-startTime);
        TrialStartTime = millis();
        state = 5;
      }
      break;

    case 5:
      currentTime = millis();
      OdorFun();

      // end trial:
      if (OdorDelivered == OdorToDo) {
        digitalWrite(trial_on_ttl, LOW);
        Serial.print(4);
        Serial.print(0);
        Serial.print(0);
        Serial.println();

        state = 0;
        idx = 0;
      }

      break;
  }

}
