 /* 
 este programa  lee entradas de sensores industriales 
 los cuales tienen una salida de 0 a 20 mili amperios
 se lee los datos de 3 sensores y se envian a la red 
 haciendo uso de un modulo wifi, tambien se hiberna cada 5 minutos
 */
 
 // incluye lbreria para el modulo wifi
#include <WaspWIFI.h>
#include <currentLoop.h>
// Instantiate currentLoop object in channel 1.
float current;

// selecciona cual es la posicion del modulo wifi
uint8_t socket=SOCKET0;
uint8_t status;
uint8_t counter=0;
char body[100];
unsigned long previous;
//se declara las vartiables para los sensores
float value_temperature;
//variables para iniciar la conexion wifi
#define ESSID "JOTA"
#define AUTHKEY "initec123"
// el host y la url
//char HOST[] = "http://estacion.waposat.com";
//char URL[]  = "/monitor/";

char HOST[] = "monitoreo.waposat.com";
char URL[]  = "GET$/monitor/abc|123|";



///declaramos eltiempo de hibernacion
char hibernateTime[] = "00:00:05:00";



void setup()
{
 
   ///////////////////////////////////////////
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
PWR.ifHibernate();

}

void loop()
{///////////////////////////////////////////////
    // 1. Hibernate interruption
    ////////////////////////////////////////////////

    // 1.1 If Hibernate has been captured, execute the associated function
   
  
      if( intFlag & HIB_INT )
    {
        hibInterrupt();
    }
    
  //////////////////////////////
  
 // Get the sensor value in integer format (0-1023)
  int value = currentLoopBoard.readChannel(CHANNEL1); 
  USB.print("Int value read from channel 1: ");
  USB.println(value);

  // Get the sensor value as a voltage in Volts
  float voltage = currentLoopBoard.readVoltage(CHANNEL1); 
  USB.print("Voltage value rad from channel 1: ");
  USB.print(voltage);
  USB.println("V");

  // Get the sensor value as a current in mA
  float current = currentLoopBoard.readCurrent(CHANNEL1);
  USB.print("Current value read from channel 1: ");
  USB.print(current);
  USB.println("mA");

  USB.println("***************************************");
  USB.print("\n");

  delay(1000);  
///////////////////
 
////////////////////  
  char float_str_current_turbides[10];
dtostrf( current, 1, 3, float_str_current_turbides);

 // Get the sensor value in integer format (0-1023)
   value = currentLoopBoard.readChannel(CHANNEL2); 
  USB.print("Int value read from channel 1: ");
  USB.println(value);

  // Get the sensor value as a voltage in Volts
   voltage = currentLoopBoard.readVoltage(CHANNEL2); 
  USB.print("Voltage value rad from channel 1: ");
  USB.print(voltage);
  USB.println("V");

  // Get the sensor value as a current in mA
   current = currentLoopBoard.readCurrent(CHANNEL2);
  USB.print("Current value read from channel 1: ");
  USB.print(current);
  USB.println("mA");

  USB.println("***************************************");
  USB.print("\n");

  delay(1000);  
///////////////////
 
char float_str_current_ph[10];
dtostrf( current, 1, 3, float_str_current_ph);
 
 // Get the sensor value in integer format (0-1023)
   value = currentLoopBoard.readChannel(CHANNEL3); 
  USB.print("Int value read from channel 1: ");
  USB.println(value);

  // Get the sensor value as a voltage in Volts
  voltage = currentLoopBoard.readVoltage(CHANNEL3); 
  USB.print("Voltage value rad from channel 1: ");
  USB.print(voltage);
  USB.println("V");

  // Get the sensor value as a current in mA
   current = currentLoopBoard.readCurrent(CHANNEL3);
  USB.print("Current value read from channel 1: ");
  USB.print(current);
  USB.println("mA");

  USB.println("***************************************");
  USB.print("\n");

  delay(1000);  
/////////////////// 
  char float_str_current_cloro[10];
dtostrf( current, 1, 3, float_str_current_cloro);

  ///////////////////////////////
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
  previous=millis();
  
  // Join AP
  if(WIFI.join(ESSID))
  {
    
  
    snprintf( body, sizeof(body), "8|%s|9|%s|10|%s",float_str_current_turbides,float_str_current_ph,float_str_current_cloro);
    USB.println(body);
    status = WIFI.getURL(DNS, HOST, URL, body); 
     if( status == 1)
    {
      USB.println(F("\nHTTP query OK."));
      USB.print(F("WIFI.answer:"));
      USB.println(WIFI.answer);
  // Set Waspmote to Hibernate, waking up after "hibernateTime"
    
    ////////////////////////////////////////////////
    // 4. Entering Hibernate mode
    ////////////////////////////////////////////////
    USB.println(F("enter hibernate mode"));
    delay(5000);
WIFI.OFF();  
    // Set Waspmote to Hibernate, waking up after "hibernateTime"
    PWR.hibernate(hibernateTime, RTC_OFFSET, RTC_ALM1_MODE2);
  
  
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
    USB.println(millis()-previous);  
  }  
  
  // Switch WiFi OFF
  WIFI.OFF();  
  
}

////////////////////////////////////////////////
// HIbernate Subroutine.
////////////////////////////////////////////////
void hibInterrupt()
{
    USB.println(F("---------------------"));
    USB.println(F("Hibernate Interruption captured"));
    USB.println(F("---------------------"));

    // Clear Flag 
    intFlag &= ~(HIB_INT);  
    delay(2000);
}

