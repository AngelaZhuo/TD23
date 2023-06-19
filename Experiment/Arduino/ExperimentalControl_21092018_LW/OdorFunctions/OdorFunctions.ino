#define SOLENOID1 29
#define SOLENOID2 28
#define SOLENOID3 27
#define SOLENOID4 26
#define SOLENOID5 25
#define SOLENOID6 24
#define SOLENOID7 23
#define SOLENOID8 22

#define ADC_PIN   49
#define DAC1_PIN  53
#define DAC2_PIN  48

#define DIGITAL1 62
#define LaserTrig  62
#define DIGITAL2 63
#define FVTrig  63
#define TrialTrig  64
#define DIGITAL4  65
#define DIGITAL7  68
#define DIGITAL8  69

int resp;
char buffer[128];
uint8_t idx = 0;
char *argv[8];
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
    if (argCount == maxArgs-1)
      break;
    while (*line != '\0' && *line != ',' && *line != ' ' && 
      *line != '\t' && *line != '\n') 
      line++;             // skip the argument until ...
  }
  *argv = '\0';                 // mark the end of argument list 
}


// This function checks and activate specific valve.
void ValveOnOff(uint8_t c ){
  if (strlen(argv[1]) > 0 && strlen(argv[2]) > 0) {
    arg1 = atoi(argv[1]);
    arg2 = atoi(argv[2]);
    if (arg1 > 0 && arg1 < 128 && arg2 > 0 && arg2 < 33) {
      if (argv[3] == '\0') {
        if (resp = ValveStatus((uint8_t)arg1, (uint8_t)arg2, &c)) {
          Serial.print("Error ");
          Serial.println(resp);
        } 
        else if (c == OFF)
          Serial.println("off");
        else 
          Serial.println("on");
      } 
      else if (strcmp(argv[3], "on") == 0) {
        if (resp = SetValve((uint8_t)arg1, (uint8_t)arg2, (uint8_t)ON)) {
          Serial.print("Error ");
          Serial.println(resp);
        } 
        else
          Serial.println("valve set");
      } 
      else if (strcmp(argv[3], "off") == 0) {
        if (resp = SetValve((uint8_t)arg1, (uint8_t)arg2, (uint8_t)OFF)) {
          Serial.print("Error ");
          Serial.println(resp);
        } 
        else
          Serial.println("valve cleared");
      } 
      else {
        Serial.println("valve <DEVICE> <N> {on,off}");
      }
    } 
    else {
      Serial.println("valve <DEVICE> <N> {on,off}, N = {1..32}");
    }
  } 
  else {
    Serial.println("valve <DEVICE> <N> {on,off}");
  }
}

// This function checks and activate specific vial.
void VialOnOff(uint8_t c){
  if (strlen(argv[1]) > 0 && strlen(argv[2]) > 0) {
    arg1 = atoi(argv[1]);
    arg2 = atoi(argv[2]);
    if (arg1 > 0 && arg1 < 128 && arg2 > 0 && arg2 < 17) {
      if (argv[3] == '\0') {
        if (resp = VialStatus((uint8_t)arg1, (uint8_t)arg2, &c)) {
          Serial.print("Error ");
          Serial.println(21);
          //Serial.println(resp);
        } 
        else if (c == OFF)
          Serial.println("off");
        else 
          Serial.println("on");
      } 
      else if (strcmp(argv[3], "on") == 0) {
        if (resp = SetVial((uint8_t)arg1, (uint8_t)arg2, (uint8_t)ON)) {
          Serial.print("Error ");
          //Serial.println(22);
          Serial.println(resp);
        } 
        else{
          Serial.println("vial set");
          
          Serial1.write(0x0c); // clear the display
          delay(10);
          Serial1.print("vial "); 
          Serial1.print(arg2);
          Serial1.println(" set");
        }
      } 
      else if (strcmp(argv[3], "off") == 0) {
        if (resp = SetVial((uint8_t)arg1, (uint8_t)arg2, (uint8_t)OFF)) {
          Serial.print("Error ");
          Serial.println(23);
        } 
        else{
          Serial.println("vial cleared");
          Serial1.write(0x0c); // clear the display
          delay(10);
          Serial1.print("vial "); 
          Serial1.print(arg2);
          Serial1.println(" cleared");
        }
      } 
      else {
        Serial.println("vial <DEVICE> <N> {on,off}");
      }
    } 
    else {
      Serial.println("vial <DEVICE> <N> {on,off}, N = {1..16}");
    }
  } 
  else {
    Serial.println("vial <DEVICE> <N> {on,off}");
  }
}

// This function Activate specific vial with Dummy.
void VialDummyOn(uint8_t c){
        if (strlen(argv[1]) > 0 && strlen(argv[2]) > 0) {
          arg1 = atoi(argv[1]);
          arg2 = atoi(argv[2]);
          if (arg1 > 0 && arg1 < 128 && arg2 > 0 && arg2 < 17) {
            if ((resp = VialOn((uint8_t)arg1, (uint8_t)arg2))||
                (resp = SetValve((uint8_t)arg1, 5, (uint8_t)OFF))) {
              Serial.print("Error ");
              Serial.println(resp);
            } else
              Serial.println("vial and dummy on");
          } else {
            Serial.println("vialOn <DEVICE> <N>, N = {1..16}");
          }
        } else {
          Serial.println("vialOn <DEVICE> <N>");
        }
      }

// This function Deactivate specific vial with Dummy.
void VialDummyOff(uint8_t c){
        if (strlen(argv[1]) > 0 && strlen(argv[2]) > 0) {
          arg1 = atoi(argv[1]);
          arg2 = atoi(argv[2]);
          if (arg1 > 0 && arg1 < 128 && arg2 > 0 && arg2 < 17) {
            if ((resp = VialOff((uint8_t)arg1, (uint8_t)arg2))||
                (resp = SetValve((uint8_t)arg1, 5, (uint8_t)ON))) {
              Serial.print("Error ");
              Serial.println(resp);
            } else
              Serial.println("vial and dummy off");
          } else {
            Serial.println("vialOff <DEVICE> <N>, N = {1..16}");
          }
        } else {
          Serial.println("vialOff <DEVICE> <N>");
        }
      } 
      
      
void FlowChangeAnalog(uint8_t c){
  if (strlen(argv[1]) > 0 && strlen(argv[2]) > 0) {
    arg1 = atoi(argv[1]);
    arg2 = atoi(argv[2]);
    if (arg1 > 0 && arg1 < 128 && arg2 > 0 && arg2 < 3) {
      if (argv[3] == '\0') {
        float value;
        if (resp = ReadMFC((uint8_t)arg1, (uint8_t)arg2, &value)) {
          Serial.print("Error ");
          Serial.println(resp);
        } 
        else 
          Serial.println(value);
      } 
      else {
        float param = atof(argv[3]);
        if (resp = analogSetMFC((uint8_t)arg1, (uint8_t)arg2, param)) {
          Serial.print("Error ");
          Serial.println(resp);
        } 
        else
          Serial.println("MFC set");
      }
    } 
    else {
      Serial.println("MFC <DEVICE> <N> {value}, N = {1..2}");
    }
  } 
  else {
    Serial.println("MFC <DEVICE> <N> {value}");
  }
}  

void FlowChangeSerial(uint8_t c){
  if (strlen(argv[1]) > 0 && strlen(argv[2]) > 0) {
    arg1 = atoi(argv[1]);
    arg2 = atoi(argv[2]);
    int param = atoi(argv[3]);
    if (arg1 > 0 && arg1 < 128 && arg2 > 0 && arg2 < 3) {
      if (resp = serialSetMFC((uint8_t)arg1, (uint8_t)arg2, param)) {
        Serial.print("Error ");
        Serial.println(resp);
      } 
      else
        Serial.println("sMFC set");
    } 
    else {
      Serial.println("sMFC <DEVICE> <N> {value}, N = {1..2}, ");
    }
  } 
  else {
    Serial.println("sMFC <DEVICE> <N> {value}");
  }
}

void SetAnalogChannel(uint8_t c){
if (strlen(argv[1]) > 0 && strlen(argv[2]) > 0 && strlen(argv[3]) > 0) {
          arg1 = atoi(argv[1]);
          arg2 = atoi(argv[2]);
          float param = atof(argv[3]);
          if (arg1 > 0 && arg1 < 128 && arg2 > 0 && arg2 < 3) {
            if (resp = SetAnalog((uint8_t)arg1, (uint8_t)arg2, param)) {
              Serial.print("Error ");
              Serial.println(resp);
            } 
            else
              Serial.println("analog-out set");
          } 
          else {
            Serial.println("analogSet <DEVICE> <N> {value}, N = {1..2}");
          }
        } 
        else {
          Serial.println("analogSet <DEVICE> <N> {value}");
        }
}

void ReadAnalogChannel(uint8_t c){
if (strlen(argv[1]) > 0 && strlen(argv[2]) > 0) {
          arg1 = atoi(argv[1]);
          arg2 = atoi(argv[2]);
          if (arg1 > 0 && arg1 < 128 && arg2 > 0 && arg2 < 7) {
            float value;
            if (resp = ReadAnalog((uint8_t)arg1, (uint8_t)arg2, &value)) {
              Serial.print("Error ");
              Serial.println(resp);
            } 
            else 
              Serial.println(value);
          } 
          else {
            Serial.println("analogRead <DEVICE> <N> {value}, N = {1..6}");
          }
        } 
        else {
          Serial.println("analogRead <DEVICE> <N> {value}");
        }
}

void ActivateDigitalChan(uint8_t){
    // set or read a digital port
    // port range: 1 to 2
    if (strlen(argv[1]) > 0) {
      arg1 = atoi(argv[1]);
      if ((arg1 > 0) && (arg1 < 3)) {
        if (argv[2] == '\0') {
          switch (arg1) {
            case 1:  currentstate = digitalRead(LaserTrig); break;
            case 2:  currentstate = digitalRead(DIGITAL2); break;
          }
          if (currentstate == HIGH)
            Serial.println("high");
          else 
            Serial.println("low");
        } else if (strcmp(argv[2], "high") == 0) {
          switch (arg1) {
            case 1:  digitalWrite(DIGITAL1, HIGH); break;
            case 2:  digitalWrite(DIGITAL2, HIGH); break;
          }
        } else if (strcmp(argv[2], "low") == 0) {
          switch (arg1) {
            case 1:  digitalWrite(DIGITAL1, LOW); break;
            case 2:  digitalWrite(DIGITAL2, LOW); break;
          }
        } else if (strcmp(argv[2], "input") == 0) {
          switch (arg1) {
            case 1:  pinMode(DIGITAL1, INPUT); break;
            case 2:  pinMode(DIGITAL2, INPUT); break;
          }
        } else if (strcmp(argv[2], "output") == 0) {
          switch (arg1) {
            case 1:  pinMode(DIGITAL1, OUTPUT); break;
            case 2:  pinMode(DIGITAL2, OUTPUT); break;
          }
        } else {
          Serial.println("digital <N> {high,low,input,output}");
        }
      } else {
        Serial.println("digital <N> {high,low,input,output}, N = {1..2}");
      }
    } else {
      Serial.println("digital <N> {high,low,input,output}");
    }
}
    
void SetDigitalChannel(uint8_t c){
  if (strlen(argv[1]) > 0 && strlen(argv[2]) > 0 && strlen(argv[3]) > 0) {
          arg1 = atoi(argv[1]);
          arg2 = atoi(argv[2]);
          arg3 = atoi(argv[3]);
          if (arg1 > 0 && arg1 < 128 && arg2 > 0 && arg2 < 7 && arg3 >= 0 && arg3 < 2) {
            if (resp = SetDigital((uint8_t)arg1, (uint8_t)arg2, (uint8_t)arg3)) {
              Serial.print("Error ");
              Serial.println(resp);
            } 
            else
              Serial.println("digital pin set");
          } 
          else {
            Serial.println("digitalSet <DEVICE> <N> {value}, N = {LOW, HIGH}");
          }
        } 
        else {
          Serial.println("digitalSet <DEVICE> <N> {value}");
        }
}

void SetDigitalMode(uint8_t c){
  if (strlen(argv[1]) > 0 && strlen(argv[2]) > 0 && strlen(argv[3]) > 0) {
          arg1 = atoi(argv[1]);
          arg2 = atoi(argv[2]);
          arg3 = atoi(argv[3]);
          if (arg1 > 0 && arg1 < 128 && arg2 > 0 && arg2 < 7 && arg3 >= 0 && arg3 < 2) {
            if (resp = ModeDigital((uint8_t)arg1, (uint8_t)arg2, (uint8_t)arg3)) {
              Serial.print("Error ");
              Serial.println(resp);
            } else
              Serial.println("digital mode set");
          } else {
            Serial.println("digitalMode <DEVICE> <N> {value}, N = {LOW, HIGH}");
          }
        } else {
          Serial.println("digitalMode <DEVICE> <N> {value}");
        }
}
void SolenoidOnOff(uint8_t c, char *argv[8]){
    // set or read a solenoid valve
    // solenoid range: 1 to 8
        if (strlen(argv[1]) > 0) {
          int arg1 = atoi(argv[1]);
          uint8_t Chan = SOLENOID1+1-arg1;
          if ((arg1 > 0) && (arg1 < 9)) {
            if (strcmp(argv[2], "on") == 0) {
              Serial1.print(Chan);
              Serial1.println(" on");
              digitalWrite(Chan, HIGH);
            } else if (strcmp(argv[2], "off") == 0) {
              Serial1.print(Chan);
              Serial1.println(" off");
              digitalWrite(Chan, LOW);
              }
            } else {
              Serial.println("solenoid <N> {on,off}");
            }
          } else {
            Serial.println("solenoid <N> {on,off}, N = {1..8}");
          } // 
}


// This function Activate specific vial with Dummy.
void VialDummyOn( char *argv[8]){
  int arg1, arg2, resp;
        if (strlen(argv[1]) > 0 && strlen(argv[2]) > 0) {
          arg1 = atoi(argv[1]);
          arg2 = atoi(argv[2]);
          Serial.println(arg1);
          Serial.println(arg2);
          if (arg1 > 0 && arg1 < 128 && arg2 > 0 && arg2 < 17) {
            if (resp = VialOn((uint8_t)arg1, (uint8_t)arg2)) {
              Serial.print("Error ");
              Serial.println(resp);
            } else
              Serial.println("vial and dummy on");
          } else {
            Serial.println("vialOn <DEVICE> <N>, N = {1..16}");
          }
        } else {
          Serial.println("vialOn <DEVICE> <N>");
        }
      }
void ReadDigitalChannel(uint8_t c){
  if (strlen(argv[1]) > 0 && strlen(argv[2]) > 0) {
    arg1 = atoi(argv[1]);
    arg2 = atoi(argv[2]);
    if (arg1 > 0 && arg1 < 128 && arg2 > 0 && arg2 < 7) {
      uint8_t value;
      if (resp = ReadDigital((uint8_t)arg1, (uint8_t)arg2, &value)) {
        Serial.print("Error ");
        Serial.println(resp);
      } 
      else 
        Serial.println(value);
    } 
    else {
      Serial.println("digitalRead <DEVICE> <N> {value}, N = {1..6}");
    }
  } 
  else {
    Serial.println("digitalRead <DEVICE> <N> {value}");
  }
}

