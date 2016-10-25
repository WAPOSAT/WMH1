
  // incluye lbreria para el modulo wifi
#include <WaspWIFI.h>
//incluye libreria para los sensores Smart Water
#include <WaspSensorSW.h>
// selecciona cual es la posicion del modulo wifi
uint8_t socket=SOCKET0;
uint8_t status;
uint8_t counter=0,counter2=0;
char body[200];
unsigned long previous;
//variables conductividad

float value_cond;
float value_calculated2;

// Value 1 used to calibrate the sensor
#define point1_cond 10500
// Value 2 used to calibrate the sensor
#define point2_cond 40000

// Point 1 of the calibration 
#define point1_cal 197.00
// Point 2 of the calibration 
#define point2_cal 150.00

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
conductivityClass ConductivitySensor;
// el host y la url
char HOST[] = "estacion.waposat.com";
char URL[]  = "GET$/Template/InsertData4.php?";
///declaramos eltiempo de hibernacion
char hibernateTime[] = "00:00:10:00";




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
//calibrandoconductivida
ConductivitySensor.setCalibrationPoints(point1_cond, point1_cal, point2_cond, point2_cal);
  delay(2000);

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
///leendo conductividaD
  value_cond = ConductivitySensor.readConductivity();
  // Conversion from resistance into ms/cm
  value_calculated2 = ConductivitySensor.conductivityConversion(value_cond);
  //////////////////////////////
  // Reading of the ORP sensor
  value_battery=PWR.getBatteryVolts();
  
  value_orp = ORPSensor.readORP();
  value_temperature = TemperatureSensor.readTemperature();
  // Apply the calibration offset
  
  value_calculated = 1000*(value_orp - calibration_offset);
  char float_str_orp[10];
dtostrf( value_calculated, 1, 3, float_str_orp);

char float_str_temp[10];
dtostrf( value_temperature, 1, 3, float_str_temp);
char float_str_cond[10];
dtostrf( value_calculated2, 1, 3, float_str_cond);
  ///////////////////////////////
  char float_str_battery[10];
  dtostrf( value_battery,1,3,float_str_battery);
  
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
   USB.print(PWR.getBatteryLevel(),DEC);
//  USB.print(value_battery,DEC);
  USB.print(F(" %"));
  
  // Show the battery Volts
  USB.print(F(" | Battery (Volts): "));
  USB.print(value_battery);
  USB.println(F(" V")); 
//////////////
  USB.print(F("Conductivity Output Resistance: "));
  USB.print(value_cond);


  // Print of the results
  USB.print(F(" Conductivity of the solution (mS/cm): "));
  USB.println(value_calculated2); 

////////  
    USB.println();
    USB.print(F(" ORP aproximado: "));
    USB.print(value_calculated);
    USB.println(F("mili volts"));  
    USB.println(F("Temperatura (grados centigrados ): "));
    USB.println(value_temperature);
    USB.println();
  
    snprintf( body, sizeof(body), "equipo=18&sensor1=2&sensor2=5&sensor3=6&sensor4=7&valor1=%s&valor2=%s&valor3=%s&valor4=%s", float_str_temp, float_str_orp,float_str_cond,float_str_battery);
    USB.println(body);
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
    

    
   // Do whatever your code needs
   
   

  //USB.println(F("enter hibernate mode"));

  // Set Waspmote to Hibernate, waking up after 10 seconds
  //PWR.hibernate("00:00:05:00",RTC_OFFSET,RTC_ALM1_MODE2);
  
    
    }
    
    else
    {
      counter2=counter2+1;
      USB.println(F("\nHTTP query ERROR"));
   counter2=counter2+1;
  if(counter2>2){
    USB.println(F("enter hibernate mode"));
    delay(5000);
WIFI.OFF();  
    // Set Waspmote to Hibernate, waking up after "hibernateTime"
    PWR.hibernate("00:00:05:00", RTC_OFFSET, RTC_ALM1_MODE2);  
  }  
  }
  }
  else
  {
    counter2=counter2+1;   
    USB.print(F("ERROR Connecting to AP."));  
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);  
    
  if(counter2>2){
    USB.println(F("enter hibernate mode"));
    delay(5000);
WIFI.OFF();  
    // Set Waspmote to Hibernate, waking up after "hibernateTime"
    PWR.hibernate("00:00:05:00", RTC_OFFSET, RTC_ALM1_MODE2);  
  }  
}  
  
  // Switch WiFi OFF
//  WIFI.OFF();  
  
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


