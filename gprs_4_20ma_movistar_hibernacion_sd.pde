#include "WaspGPRS_SIM928A.h"
#include <WaspWIFI.h>
//incluye libreria para los sensores Smart Water
#include <WaspSensorSW.h>
#include <currentLoop.h>


char apn[] = "movistar.pe";
char login[] = "movistar@datos";
char password[] = "movistar";


uint8_t sd_answer;
char filename[15];
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
char hibernateTime[] = "00:00:00:20";


void setup()
{  
    PWR.ifHibernate();

  USB.ON();
  USB.println(F("PWR_3 example"));
  
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

 // Sets the 5V switch ON
  currentLoopBoard.ON(SUPPLY5V);
  delay(1000);

  // Sets the 12V switch ON
  currentLoopBoard.ON(SUPPLY12V); 
  delay(1000); 
        SD.ON();
  
  // Powers RTC up, init I2C bus and read initial values
  USB.println(F("Init RTC"));
  RTC.ON();
}

void loop()
{
    if( intFlag & HIB_INT )
  {
    USB.println(F("---------------------"));
    USB.println(F("Hibernate Interruption captured"));
    USB.println(F("---------------------"));
    intFlag &= ~(HIB_INT);
    delay(5000);
  }
  
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
  
  char float_str_current_turvides[10];
dtostrf( current, 1, 3, float_str_current_turvides);

snprintf(url,sizeof(url), "http://monitoreo.waposat.com/monitor/abc|123|12|%s",float_str_current_turvides);

/////////////////////////
 USB.print(F("Time [day of week, YY/MM/DD, HH:MM:SS]:"));
  USB.println(RTC.getTime());   
    
    /////////////////////////////////////////////////////////////
    // 2. Create file according to TIME with the following format:
    // filename: [HHMMSS.TXT]
    /////////////////////////////////////////////////////////////
    sprintf(filename,"%02u%02u%02u%02u.TXT",RTC.date,RTC.hour, RTC.minute, RTC.second);
    if(SD.create(filename))
    {    
      USB.print(F("2 - file created:"));
      USB.println(filename);
    }
    else 
    {
      USB.println(F("2 - file NOT created")); // only one file per second
    } 
    // char hola[50]="hola";
      
      
    sd_answer = SD.append(filename, url);
  
  if( sd_answer == 1 )
  {
    USB.println(F("\n2 - appends \"hello\" at the end of the file"));
  }
  else 
  {
    USB.println(F("\n2 - append error"));
  }
  
  // show file
  SD.showFile(filename);
  delay(2000);    

///////////////////////////////

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
            //    snprintf(url,sizeof(url), "http://monitoreo.waposat.com/monitor/abc|123|12|%s",float_str_current_turvides);

//sprintf(url, "http://estacion.waposat.com/Template/InsertData3.php?equipo=18&sensor1=2&sensor2=5&sensor3=7&valor1=%s&valor2=%s&valor3=%s", float_str_temp, float_str_orp,float_str_battery);

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
                  ///////////////////////  
                        USB.println(F("enter hibernate mode"));
    delay(5000);

    // Set Waspmote to Hibernate, waking up after "hibernateTime"
    PWR.hibernate(hibernateTime, RTC_OFFSET, RTC_ALM1_MODE2);
    /////////////////
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

void hibInterrupt()
{
    USB.println(F("---------------------"));
    USB.println(F("Hibernate Interruption captured"));
    USB.println(F("---------------------"));

    // Clear Flag 
    intFlag &= ~(HIB_INT);  
    delay(2000);
}


