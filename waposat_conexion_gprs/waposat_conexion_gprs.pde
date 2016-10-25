/*
Este programa lee los sensores de conductividad 
orp bateria y temperatura y envia los datos obtenidos
a la red  haciendo uso de la red movil gprs 
*/
#include "WaspGPRS_SIM928A.h"
#include <WaspWIFI.h>
//incluye libreria para los sensores Smart Water
#include <WaspSensorSW.h>


char apn[] = "ba.amx";
char login[] = "amx";
char password[] = "amx";


int answer;
char url[150];
unsigned int counter = 0;
// selecciona cual es la posicion del modulo wifi
uint8_t socket=SOCKET0;
uint8_t status;
//uint8_t counter=0;
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
//char HOST[] = "estacion.waposat.com";
//char URL[]  = "GET$/Template/InsertData3.php?";
///declaramos eltiempo de hibernacion
//char hibernateTime[] = "00:00:05:00";


void setup()
{  
     SensorSW.ON();
     // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));

    USB.println(F("---******************************************************************************---"));
    USB.println(F("GET request to the libelium's test url..."));
    USB.println(F("You can use this php to test the HTTP connection of the module."));
    USB.println(F("The php returns the parameters that the user sends with the URL."));
    USB.println(F("In this case the loop counter (counter) and the RTC temperature (temp)."));
    USB.println(F("The syntax to add parameters is below:"));
    USB.println(F("getpost_frame_parser.php?parameter1=value1&parameter2=value2&...&last_parameter=last_value"));
    USB.println(F("---******************************************************************************---"));

    // 1. sets operator parameters
    GPRS_SIM928A.set_APN(apn, login, password);
    // And shows them
    GPRS_SIM928A.show_APN();
    USB.println(F("---******************************************************************************---"));

}

void loop()
{//////////////////////////
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

  // get actual time
  previous=millis();
  
 
    
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
  /*
    snprintf( body, sizeof(body), "equipo=20&sensor1=2&sensor2=5&sensor3=7&valor1=%s&valor2=%s&valor3=%s", float_str_temp, float_str_orp,float_str_battery);
*/  
  ///////////////////////////////
    // 2. activate the GPRS_SIM928A module:
    answer = GPRS_SIM928A.ON(); 
    if ((answer == 1) || (answer == -3))
    { 
        USB.println(F("GPRS_SIM928A module ready..."));

        // 3. set pin code:
  /*      USB.println(F("Setting PIN code..."));
        // **** must be substituted by the SIM code
     if (GPRS_SIM928A.setPIN("1234") == 1) 
        {
            USB.println(F("PIN code accepted"));
        }
        else
        {
            USB.println(F("PIN code incorrect"));
        }
*/
        // 4. wait for connection to the network:
        answer = GPRS_SIM928A.check(180);    
        if (answer == 1)
        {             
            USB.println(F("GPRS_SIM928A module connected to the network..."));

            // 5. configures GPRS connection for HTTP or FTP applications:
            answer = GPRS_SIM928A.configureGPRS_HTTP_FTP(1);
            if (answer == 1)
            {
                USB.println(F("Get the URL with GET request..."));          
                RTC.ON();

                sprintf(url, "http://estacion.waposat.com/Template/InsertData3.php?equipo=18&sensor1=2&sensor2=5&sensor3=7&valor1=%s&valor2=%s&valor3=%s", float_str_temp, float_str_orp,float_str_battery);

                USB.println(F("-------------------------------------------"));
                USB.println(url);                
                USB.println(F("-------------------------------------------"));

                // 6. gets URL from the solicited URL
                answer = GPRS_SIM928A.readURL(url, 1);

                // check answer
                if ( answer == 1)
                {
                    USB.println(F("Done"));  
                    USB.println(F("The server has replied with:")); 
                    USB.println(GPRS_SIM928A.buffer_GPRS);
                }
                else if (answer < -9)
                {
                    USB.print(F("Failed. Error code: "));
                    USB.println(answer, DEC);
                    USB.print(F("CME error code: "));
                    USB.println(GPRS_SIM928A.CME_CMS_code, DEC);
                }
                else 
                {
                    USB.print(F("Failed. Error code: "));
                    USB.println(answer, DEC);
                }

            }
            else
            {
                USB.println(F("Configuration 1 failed. Error code: "));
                USB.println(answer, DEC);
            }
        }
        else
        {
            USB.println(F("GPRS_SIM928A module cannot connect to the network"));     
        }
    }
    else
    {
        USB.println(F("GPRS_SIM928A module not ready"));    
    }
    
    // 7. powers off the GPRS_SIM928A module
    GPRS_SIM928A.OFF(); 

    counter++;

    delay(5000);

}

