#include <Wire.h>

#define SET_VALVE     1
#define SET_VIAL      2
#define VALVE_STATUS  3
#define VIAL_STATUS   4
#define aSET_MFC       5
#define READ_MFC      6
#define VIAL_ON       7
#define VIAL_OFF      8
#define SET_ANALOG    9
#define READ_ANALOG  10
#define SET_DIGITAL  11
#define READ_DIGITAL 12
#define MODE_DIGITAL 13
#define sSET_MFC       14


#define OFF 0
#define ON  1

// This function will set or clear a valve
// The arguments to the function is the device address, the valve number and the state to set it to 

int SetValve(uint8_t device, uint8_t valve, uint8_t state) {
  uint8_t txbuff[3];
  // Check to make sure the arguments are sane
  if (device > 127 || valve == 0 || valve > 32 || state > 1)
    return -1; // No, error return
  // Issue set valve command
  txbuff[0] = SET_VALVE; // command
  txbuff[1] = valve;     // valve to update
  txbuff[2] = state;     // state (ON or OFF)
  Wire.beginTransmission(device); // This is the I2C address of the device
  Wire.write(txbuff, 3);
  Wire.endTransmission();
  // Read back the valve status to verify that it got updated
  txbuff[0] = VALVE_STATUS;
  txbuff[1] = valve;
  Wire.beginTransmission(device);
  Wire.write(txbuff, 2);
  Wire.endTransmission();
  if (!Wire.requestFrom(device, (uint8_t)1))
    return -1; // Error return, command failed
  int value = Wire.read();
  if (value != (int)state)
    return -1; // Error return, valve status state did not match the set valve state
  return 0;    // all OK
}

// This function will return the status of a valve (ON or OFF)
// The arguments to the function is the device address, the valve number and a pointer to the return state
int ValveStatus(uint8_t device, uint8_t valve, uint8_t * state) {
  uint8_t txbuff[2];
  // Check to make sure the arguments are sane
  if (device > 127 || valve == 0 || valve > 32)
    return -1;
  // Issue the valve state command
  txbuff[0] = VALVE_STATUS;
  txbuff[1] = valve;
  Wire.beginTransmission(device);
  Wire.write(txbuff, 2);
  Wire.endTransmission();
  if (!Wire.requestFrom(device, (uint8_t)1))
    return -1; // Error return, command failed
  int value = Wire.read();
  if (value < 0 || value > 1)
    return -1; // Error return, invalid return value
  if (value == 0)
    *state = (uint8_t)OFF;
  else
    *state = (uint8_t)ON;
  return 0;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// This function will set or clear a vial (a pair of valves)
// The arguments to the function is the device address, the vial number and the state to set it to 
int SetVial(uint8_t device, uint8_t vial, uint8_t state) {
  uint8_t txbuff[3];
  int value;
  // Check to make sure the arguments are sane
  if (device > 127 || vial == 0 || vial > 16 || state > 1)
    return -1; // No, error return
  // Issue set vial command
  txbuff[0] = SET_VIAL; // command
  txbuff[1] = vial;     // vial to update
  txbuff[2] = state;    // state (ON or OFF)
  Wire.beginTransmission(device); // This is the I2C address of the device
  Wire.write(txbuff, 3);
  Wire.endTransmission();    
  // Read back the vial status to verify that it got updated
  txbuff[0] = VIAL_STATUS;
  txbuff[1] = vial;
  Wire.beginTransmission(device);
  Wire.write(txbuff, 2);
  Wire.endTransmission();
  if (!Wire.requestFrom(device, (uint8_t)1))
    return -3; // Error return, command failed
  value = Wire.read();
  if (value != (int)state)
    return -4; // Error return, vial status state did not match the set vial state
  return 0;    // all OK
}

// This function will return the status of a vial (ON or OFF)
// The arguments to the function is the device address, the vial number and a pointer to the return state
int VialStatus(uint8_t device, uint8_t vial, uint8_t * state) {
  uint8_t txbuff[2];
  // Check to make sure the arguments are sane
  if (device > 127 || vial == 0 || vial > 16)
    return -1;
  // Issue the vial state command
  txbuff[0] = VIAL_STATUS;
  txbuff[1] = vial;
  Wire.beginTransmission(device);
  Wire.write(txbuff, 2);
  Wire.endTransmission();
  if (!Wire.requestFrom(device, (uint8_t)1))
    return -1; // Error return, command failed
  int value = Wire.read();
  if (value < 0 || value > 1)
    return -1; // Error return, invalid return value
  if (value == 0)
    *state = (uint8_t)OFF;
  else
    *state = (uint8_t)ON;
  return 0;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// This function will set the MFC's flow through serial communication
// The arguments to the function is the device address, the MFC number and the flow to set 
int serialSetMFC(uint8_t device, uint8_t MFC, uint16_t flow) {
  uint8_t txbuff[4];
  // Check to make sure the arguments are sane
  if (device > 127 || MFC == 0 || MFC > 3 || flow < 0 || flow > 100)
    return -1; // No, error return
  // uint16_t intValue = param;
  // Issue set MFC command
  txbuff[0] = sSET_MFC;        // command
  txbuff[1] = MFC;                   // MFC to update
  txbuff[2] = flow & 0xff;   // low byte
  txbuff[3] = flow >> 8;        // high
  Wire.beginTransmission(device); // This is the I2C address of the device
  Wire.write(txbuff, 4);
  Wire.endTransmission();
  if (!Wire.requestFrom(device, (uint8_t)1))
    return -1; // Error return, command failed
  uint8_t reply = Wire.read();
  if (reply)
    return reply;
  return 0;    // all OK
}

// This function will set the analog value for MFC
// The arguments to the function is the device address, the MFC number and the value to set 
int analogSetMFC(uint8_t device, uint8_t MFC, float param) {
  uint8_t txbuff[4];
  // Check to make sure the arguments are sane
  if (device > 127 || MFC == 0 || MFC > 4 || param < 0.0 || param > 1.0)
    return -1; // No, error return
  uint16_t intValue = param * 65535;
  // Issue set MFC command
  txbuff[0] = aSET_MFC; // command
  txbuff[1] = MFC;     // MFC to update
  txbuff[2] = intValue & 0xff;   // low byte
  txbuff[3] = intValue >> 8;     // high
  Wire.beginTransmission(device); // This is the I2C address of the device
  Wire.write(txbuff, 4);
  Wire.endTransmission();
  if (!Wire.requestFrom(device, (uint8_t)1))
    return -1; // Error return, command failed
  uint8_t reply = Wire.read();
  if (reply)
    return reply;
  return 0;    // all OK
}

// This function will read the analog value for MFC
// The arguments to the function is the device address, the MFC number and a pointer to the return value 
int ReadMFC(uint8_t device, uint8_t MFC, float * value) {
  uint8_t txbuff[2];
  // Check to make sure the arguments are sane
  if (device > 127 || MFC == 0 || MFC > 4)
    return -1; // No, error return
  // Issue read MFC command
  txbuff[0] = READ_MFC; // command
  txbuff[1] = MFC;      // MFC to read
  Wire.beginTransmission(device); // This is the I2C address of the device
  Wire.write(txbuff, 2);
  Wire.endTransmission();
  if (!Wire.requestFrom(device, (uint8_t)2))
    return -2; // Error return, command failed
  uint8_t low = Wire.read(); //low
  uint16_t resp = Wire.read(); //high
  resp = (resp << 8) | low;
  float respf = (float)resp;
  if (respf > 1023.0)
    return -3;
  *value = respf/1023;
  return 0;    // all OK
}

// This function will exclusively set a single vial  and the dummy vial on
// The arguments to the function is the device address and the vial number 
int VialOn(uint8_t device, uint8_t vial) {
  uint8_t txbuff[2];
  // Check to make sure the arguments are sane
  if (device > 127 || vial == 0 || vial > 16)
    return -1; // No, error return
  // Issue vial on command
  txbuff[0] = VIAL_ON; // command
  txbuff[1] = vial;     // vial to update
  Wire.beginTransmission(device); // This is the I2C address of the device
  Wire.write(txbuff, 2);
  Wire.endTransmission();    
  if (!Wire.requestFrom(device, (uint8_t)1))
    return -1; // Error return, valve status command failed
  uint8_t reply = Wire.read();
  if (reply)
    return reply;
  return 0;    // all OK
}

// This function will turn off a single vial and the dummy vial
// The arguments to the function is the device address and the vial number
// The function will return error unless this and only this vial and the dummy vial are on.
int VialOff(uint8_t device, uint8_t vial) {
  uint8_t txbuff[2];
  // Check to make sure the arguments are sane
  if (device > 127 || vial == 0 || vial > 16)
    return -1; // No, error return
  // Issue vial off command
  txbuff[0] = VIAL_OFF; // command
  txbuff[1] = vial;     // vial to update
  Wire.beginTransmission(device); // This is the I2C address of the device
  Wire.write(txbuff, 2);
  Wire.endTransmission();
  if (!Wire.requestFrom(device, (uint8_t)1))
    return -1; // Error return, command failed
  uint8_t reply = Wire.read();
  if (reply)
    return reply;
  return 0;    // all OK
}

// This function will set the analog value for an analog-out channel
// The arguments to the function is the device address, the analog-out number and the value to set 
int SetAnalog(uint8_t device, uint8_t ch, float param) {
  uint8_t txbuff[4];
  // Check to make sure the arguments are sane
  if (device > 127 || ch == 0 || ch > 2 || param < 0.0 || param > 1.0)
    return -1; // No, error return
  uint16_t intValue = param * 65535;
  // Issue set analog command
  txbuff[0] = SET_ANALOG; // command
  txbuff[1] = ch;         // channel to update
  txbuff[2] = intValue & 0xff;   // low byte
  txbuff[3] = intValue >> 8;     // high
  Wire.beginTransmission(device); // This is the I2C address of the device
  Wire.write(txbuff, 4);
  Wire.endTransmission();
  if (!Wire.requestFrom(device, (uint8_t)1))
    return -1; // Error return, command failed
  uint8_t reply = Wire.read();
  if (reply)
    return reply;
  return 0;    // all OK
}

// This function will read the analog value for an analog-in channel
// The arguments to the function is the device address, the analog-in number and a pointer to the return value 
int ReadAnalog(uint8_t device, uint8_t ch, float * value) {
  uint8_t txbuff[2];
  // Check to make sure the arguments are sane
  if (device > 127 || ch == 0 || ch > 6)
    return -1; // No, error return
  // Issue read analog command
  txbuff[0] = READ_ANALOG; // command
  txbuff[1] = ch;          // channel to read
  Wire.beginTransmission(device); // This is the I2C address of the device
  Wire.write(txbuff, 2);
  Wire.endTransmission();
  if (!Wire.requestFrom(device, (uint8_t)2))
    return -2; // Error return, command failed
  uint8_t low = Wire.read(); //low
  uint16_t resp = Wire.read(); //high
  resp = (resp << 8) | low;
  float respf = (float)resp;
  if (respf > 1023.0)
    return -3;
  *value = respf/1023;
  return 0;    // all OK
}

// This function will set the digital value for a digital pin
// The arguments to the function is the device address, the pin number and the value to set 
int SetDigital(uint8_t device, uint8_t pin, uint8_t value) {
  uint8_t txbuff[3];
  // Check to make sure the arguments are sane
  if (device > 127 || pin == 0 || pin > 6 || value > 1)
    return -1; // No, error return
  // Issue set digital command
  txbuff[0] = SET_DIGITAL; // command
  txbuff[1] = pin;         // pin to update
  txbuff[2] = value;   // value
  Wire.beginTransmission(device); // This is the I2C address of the device
  Wire.write(txbuff, 3);
  Wire.endTransmission();
  if (!Wire.requestFrom(device, (uint8_t)1))
    return -1; // Error return, command failed
  uint8_t reply = Wire.read();
  if (reply)
    return reply;
  return 0;    // all OK
}

// This function will read the digital value for a digital pin
// The arguments to the function is the device address, the pin number and a pointer to the return value 
int ReadDigital(uint8_t device, uint8_t pin, uint8_t * value) {
  uint8_t txbuff[2];
  // Check to make sure the arguments are sane
  if (device > 127 || pin == 0 || pin > 6)
    return -1; // No, error return
  // Issue read analog command
  txbuff[0] = READ_DIGITAL; // command
  txbuff[1] = pin;          // pin to read
  Wire.beginTransmission(device); // This is the I2C address of the device
  Wire.write(txbuff, 2);
  Wire.endTransmission();
  if (!Wire.requestFrom(device, (uint8_t)2))
    return -2; // Error return, command failed
  uint8_t resp = Wire.read();
  if (resp > 1)
    return -3;
  *value = resp;
  return 0;    // all OK
}

// This function will set the digital mode for a digital pin
// The arguments to the function is the device address, the pin number and the mode to set 
int ModeDigital(uint8_t device, uint8_t pin, uint8_t value) {
  uint8_t txbuff[3];
  // Check to make sure the arguments are sane
  if (device > 127 || pin == 0 || pin > 6 || value > 1)
    return -1; // No, error return
  // Issue set digital command
  txbuff[0] = MODE_DIGITAL; // command
  txbuff[1] = pin;         // pin to update
  txbuff[2] = value;   // value
  Wire.beginTransmission(device); // This is the I2C address of the device
  Wire.write(txbuff, 3);
  Wire.endTransmission();
  if (!Wire.requestFrom(device, (uint8_t)1))
    return -1; // Error return, command failed
  uint8_t reply = Wire.read();
  if (reply)
    return reply;
  return 0;    // all OK
}

