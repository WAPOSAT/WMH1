// incluye lbreria para el modulo wifi
#include <WaspWIFI.h>
#include <currentLoop.h>
// Instantiate currentLoop object in channel 1.
float current;
float Max=100;

// selecciona cual es la posicion del modulo wifi
uint8_t socket=SOCKET0;
uint8_t status;
uint8_t counter=0;
char body[100];
unsigned long previous;
//se declara las vartiables para los sensores
float value_temperature;
//variables para iniciar la conexion wifi
#define ESSID "initecaruni"
#define AUTHKEY "m53h32m53h32m"
// el host y la url
//char HOST[] = "http://estacion.waposat.com";
//char URL[]  = "/monitor/";
float value_battery;
char HOST[] = "monitoreo.waposat.com";
char URL[]  = "GET$/monitor/abc|123|";



void setup()
{  ///////////////////////////////////////////
   ///activa la comunicacion por cable usb
  USB.ON();  
  
  
  // Sets the 5V switch ON
  currentLoopBoard.ON(SUPPLY5V);
  delay(100);
  
  // Sets the 12V switch ON
  currentLoopBoard.ON(SUPPLY12V); 
  delay(100); 


  // Switch ON the WiFi module on the desired socket
  if( WIFI.ON(socket) == 1 )
  {    
    USB.println(F("WiFi switched ON"));
  }
  else
  {
    USB.println(F("WiFi did not initialize correctly"));
  }
  
  // 1. Configura el protocolo de comunicacion (UDP, TCP, FTP, HTTP...)
 WIFI.setConnectionOptions(UDP);
  
  // 2.1. Configure the way the modules will resolve the IP address.
  /*** DHCP MODES ***
  * DHCP_OFF   (0): Use stored static IP address
  * DHCP_ON    (1): Get IP address and gateway from AP
  * AUTO_IP    (2): Generally used with Ad-hoc networks
  * DHCP_CACHE (3): Uses previous IP address if lease is not expired
  */  
  WIFI.setDHCPoptions(DHCP_ON);
  //WIFI.setDNS(MAIN,"8.8.8.8","www.google.com");
  // 3. set Auth key 
  WIFI.setAuthKey(WPA2,AUTHKEY); 
  
  // 4. Configure how to connect the AP
  WIFI.setJoinMode(AUTO_STOR);
  WIFI.setAuthKey(WPA2,AUTHKEY); 
  // 5. Store Values
  WIFI.storeData();
  
   USB.println(F("Set up done"));
}

void loop()
{

    //////////////////////////
///////////////////////////
value_battery=PWR.getBatteryVolts();
  char float_str_battery[10];
  dtostrf(value_battery,1,3,float_str_battery);



  // Get the sensor value in integer format (0-1023)
  int value = currentLoopBoard.readChannel(CHANNEL2); 
  USB.print("Int value read from channel 1: ");
  USB.println(value);

  // Get the sensor value as a voltage in Volts
  float voltage = currentLoopBoard.readVoltage(CHANNEL2); 
  USB.print("Voltage value rad from channel 1: ");
  USB.print(voltage);
  USB.println("V");

  // Get the sensor value as a current in mA
  float current = currentLoopBoard.readCurrent(CHANNEL2);
  USB.print("Current value read from channel 1: ");
  USB.print(current);
  USB.println("mA");
current=(current-4)*Max/16;
  USB.println("***************************************");
  USB.print("\n");

  delay(1000);  
///////////////////
 
////////////////////  
  char float_str_current_turbides[10];
dtostrf( current, 1, 3, float_str_current_turbides);

  // switch WiFi ON 
 if( WIFI.ON(socket) == 1 )
  {    
    USB.println(F("WiFi switched ON"));
  }
  else
  {
    USB.println(F("WiFi did not initialize correctly"));
  }
  
  // get actual time
  //previous=millis();
  
  // Join AP
  if(WIFI.join(ESSID))
  {
    
  
    snprintf( body, sizeof(body), "14|%s|12|%s",float_str_battery,float_str_current_turbides);
    USB.println(body);
    status = WIFI.getURL(DNS, HOST, URL, body); 
     if( status == 1)
    {
      USB.println(F("\nHTTP query OK."));
      USB.print(F("WIFI.answer:"));
      USB.println(WIFI.answer);
  // Set Waspmote to Hibernate, waking up after "hibernateTime"
    
      }
    
    else
    {
      USB.println(F("\nHTTP query ERROR"));
   
    }
  }
  else
  {    
    USB.print(F("ERROR Connecting to AP."));  
    USB.print(F(" Time(ms):"));    
   // USB.println(millis()-previous);  
  }  
  
  // Switch WiFi OFF
  WIFI.OFF();  
  
}


