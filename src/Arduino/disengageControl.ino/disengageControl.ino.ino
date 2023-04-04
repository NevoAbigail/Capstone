#include <ArduinoBLE.h>
    
 #define GREEN_PIN 23
 #define TRANSISTOR_OUT 9
 #define BAUD_RATE 9600

 #define DEBUG true

BLEService nanoService("13012F00-F8C3-4F4A-A8F4-15CD926DA146"); // BLE Service

// BLE Characteristics - custom 128-bit UUID, read and writable by central device

BLEByteCharacteristic commCharacteristic("13012F02-F8C3-4F4A-A8F4-15CD926DA146", BLERead | BLEWrite);

int password = 2;

void setup() {
    Serial.begin(BAUD_RATE);
    
    if (DEBUG) {
      while(!Serial);
    }
    
    // intitialize the LED Pins as an output
    pinMode(GREEN_PIN, OUTPUT);

    // initialize digital pin 13 (D13) as output  
    pinMode(TRANSISTOR_OUT, OUTPUT);

    // Set them to the OFF position to start with
    // The onboard RGB LED has an inverse logic - i.e. HIGH turns it off, and LOW turns in ON
    digitalWrite(GREEN_PIN, HIGH);         // will turn the LED off

    // begin initialization
    if (!BLE.begin()) {
        Serial.println("Starting BLE failed!");
        while (1);
    }


    // set advertised local name and service UUID:
    char productName[] = "SmartLock";
    BLE.setDeviceName(productName);
    BLE.setLocalName(productName);
    BLE.setAdvertisedService(nanoService);

    // add the characteristic to the service  
    /*if nothing is programmed on the central side, 
    it will use whichever characteristic is listed first here */
    nanoService.addCharacteristic(commCharacteristic);

    // add service
    BLE.addService(nanoService);

    // set the initial value for the characeristic:
    commCharacteristic.writeValue(0);

    // start advertising
    BLE.advertise();
    delay(100);
    Serial.println("Arduino Nano BLE LED Peripheral Service Started");

    Serial.print("Peripheral device MAC: ");
    Serial.println(BLE.address());
    Serial.println("Waiting for connections...");
}

void loop() {

    // listen for BLE centrals to connect:
    BLEDevice central = BLE.central();

    // if a central is connected to peripheral:
    if (central) {
        Serial.print("Connected to central: ");
        // print the central's MAC address:
        Serial.println(central.address());

        // while the central is still connected to peripheral:
        while (central.connected()) {
            // if the remote device wrote to the characteristic,
            // use the value to control the LED:
           if (commCharacteristic.written()) {
                if (commCharacteristic.value()==password) {   // any non-zero value
                    Serial.println("GREEN LED on");
                    digitalWrite(GREEN_PIN, LOW);         // LOW will turn the LED on
                    digitalWrite(TRANSISTOR_OUT, HIGH); //sets the digital pin 13 on

                    delay(15000); //waits for 15 seconds 
                    digitalWrite(GREEN_PIN, HIGH);
                    digitalWrite(TRANSISTOR_OUT,LOW); //sets the digital pin 13 off
                } else {                              // a zero value
                    Serial.println(F("GREEN LED off"));
                    digitalWrite(GREEN_PIN, HIGH);          // HIGH will turn the LED off
                    digitalWrite(TRANSISTOR_OUT,LOW); //sets the digital pin 13 off
                }
                
            } 
        }

        // when the central disconnects, print it out:
        Serial.print(F("Disconnected from central: "));
        Serial.println(central.address());
    } 

}
