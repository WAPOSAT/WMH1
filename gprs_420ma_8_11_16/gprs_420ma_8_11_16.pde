#include "WaspGPRS_SIM928A.h"
#include <WaspWIFI.h>
//incluye libreria para los sensores Smart Water
#include <WaspSensorSW.h>
#include <currentLoop.h>

char apn[] = "movistar.pe";
char login[] = "movistar@datos";
char password[] = "movistar";

char filename[]="WAPOSAT.TXT";


uint8_t sd_answer;
//char filename[15];
int answer;
char url[150];
char urlsd[150];
unsigned int counter = 0;
// selecciona cual es la posicion del modulo wifi
uint8_t socket=SOCKET0;
uint8_t status;
//uint8_t counter=0;
char body[100];

float Max=100;
float value_battery;
//char hibernateTime[] = "00:00:00:01";


void setup()
{  


    USB.ON();
    // 1. sets operator parameters
    GPRS_SIM928A.set_APN(apn, login, password);
    // And shows them
    GPRS_SIM928A.show_APN();
    USB.println(F("---******************************************************************************---"));

 // Sets the 5V switch ON
  currentLoopBoard.ON(SUPPLY5V);
  //delay(1000);

  // Sets the 12V switch ON
  currentLoopBoard.ON(SUPPLY12V); 
  //delay(1000); 
        SD.ON();

  sd_answer = SD.create(filename);
  
  if( sd_answer == 1 )
  {
    USB.println(F("file created"));
  }
  else 
  {
    USB.println(F("file NOT created"));  
  } 

  
  // Powers RTC up, init I2C bus and read initial values
  USB.println(F("Init RTC"));

  RTC.ON();

}

void loop()
{
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
  current=(current-4)*Max/16;

  USB.print("Current value read from channel 1: ");
  USB.print(current);
    USB.println("mA");

  USB.println("***************************************");
  USB.print("\n");
 
  RTC.getTime(); 
  
  char float_str_current_turvides[10];
dtostrf( current, 1, 3, float_str_current_turvides);

snprintf(url,sizeof(url), "http://monitoreo.waposat.com/monitor/abc|123|15|%s|14|%s",float_str_current_turvides,float_str_battery);
snprintf(urlsd,sizeof(urlsd), "http://monitoreo.waposat.com/monitor/abc|123|1|%02u%02u%02u%02u%02u%02u|15|%s|14|%s    ",RTC.year,RTC.month,RTC.date,RTC.hour, RTC.minute, RTC.second,float_str_current_turvides,float_str_battery);



    sd_answer = SD.appendln(filename, urlsd);
  
  if( sd_answer == 1 )
  {
    USB.println(F("\n2 - appends \"hello\" at the end of the file"));
  }
  else 
  {
    USB.println(F("\n2 - append error"));
  }
  answer = GPRS_SIM928A.ON(); 
    if ((answer == 1) || (answer == -3))
    { 
        USB.println(F("GPRS_SIM928A module ready..."));
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
//    GPRS_SIM928A.OFF(); 
}


