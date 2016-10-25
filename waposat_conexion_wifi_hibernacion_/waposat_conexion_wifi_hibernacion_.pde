/*Este programa lee los sensores de temperatura 
orp conductividad y bateria para luego enviarlos 
a la red haciendo uso de la conexion por wifi asi
mismo  despues de leer y enviar los datos se hiberna
por un tiempo determinado en este caso 5 minutos */

  // incluye lbreria para el modulo wifi
#include <WaspWIFI.h>
//incluye libreria para los sensores Smart Water
#include <WaspSensorSW.h>
// selecciona cual es la posicion del modulo wifi
uint8_t socket=SOCKET0;
uint8_t status;
uint8_t counter=0;
char body[100];
unsigned long previous;
//se declara las vartiables para los sensores
float value_orp;
float value_battery;
float value_calculated;
float value_temperature;
//variables para iniciar la conexion wifi
#define ESSID "initecaruni"
#define AUTHKEY "m53h32m53h32m"
//calibracion para los sensores
#define calibration_offset 0.0
//se objetos con las clases temperatura y orp
pt1000Class TemperatureSensor;
ORPClass ORPSensor;
// el host y la url
char HOST[] = "estacion.waposat.com";
char URL[]  = "GET$/Template/InsertData3.php?";
///declaramos eltiempo de hibernacion
char hibernateTime[] = "00:00:05:00";




void setup()
{PWR.ifHibernate();
 // activa el modulo  sensor
  SensorSW.ON();
 ///activa la comunicacion por cable usb
  USB.ON();  
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
  ///////////////////////////////////////////////
    // 1. Hibernate interruption
    ////////////////////////////////////////////////

    // 1.1 If Hibernate has been captured, execute the associated function
   
  
      if( intFlag & HIB_INT )
    {
        hibInterrupt();
    }
    
  //////////////////////////////
  // Reading of the ORP sensor
  value_battery=PWR.getBatteryVolts();
  
  value_orp = ORPSensor.readORP();
  value_temperature = TemperatureSensor.readTemperature();
  // Apply the calibration offset
  
  char float_str_battery[10];
  dtostrf(value_battery,1,3,float_str_battery);
  value_calculated = 1000*(value_orp - calibration_offset);
  char float_str_orp[10];
dtostrf( value_calculated, 1, 3, float_str_orp);

char float_str_temp[10];
dtostrf( value_temperature, 1, 3, float_str_temp);
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
    
   USB.print(F("Battery Level: "));
  USB.print(value_battery,DEC);
  USB.print(F(" %"));
  
  // Show the battery Volts
  USB.print(F(" | Battery (Volts): "));
  USB.print(PWR.getBatteryVolts());
  USB.println(F(" V")); 
  
    USB.println();
    USB.print(F(" ORP aproximado: "));
    USB.print(value_calculated);
    USB.println(F("mili volts"));  
    USB.print(F("Temperatura (grados centigrados ): "));
    USB.println(value_temperature);
    USB.println();
  
    snprintf( body, sizeof(body), "equipo=20&sensor1=2&sensor2=5&sensor3=7&valor1=%s&valor2=%s&valor3=%s", float_str_temp, float_str_orp,float_str_battery);
    status = WIFI.getURL(DNS, HOST, URL, body); 
     if( status == 1)
    {
      USB.println(F("\nHTTP query OK."));
      USB.print(F("WIFI.answer:"));
      USB.println(WIFI.answer);

    ////////////////////////////////////////////////
    // 4. Entering Hibernate mode
    ////////////////////////////////////////////////
    USB.println(F("enter hibernate mode"));
    delay(5000);
WIFI.OFF();  
    // Set Waspmote to Hibernate, waking up after "hibernateTime"
    PWR.hibernate(hibernateTime, RTC_OFFSET, RTC_ALM1_MODE2);
    
/*
        if( intFlag & HIB_INT )
  {
    USB.println(F("---------------------"));
    USB.println(F("Hibernate Interruption captured"));
    USB.println(F("---------------------"));
    intFlag &= ~(HIB_INT);
    delay(1000);
  }
    
   // Do whatever your code needs
   
   

  USB.println(F("enter hibernate mode"));

  // Set Waspmote to Hibernate, waking up after 10 seconds
  PWR.hibernate("00:00:05:00",RTC_OFFSET,RTC_ALM1_MODE2);
  
    */
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
  
  //USB.println(F("\n\n******************************************************\n\n"));
  //delay(1000);

  
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


