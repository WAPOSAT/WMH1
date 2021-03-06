#include "WaspGPRS_SIM928A.h"
#include <WaspWIFI.h>
//incluye libreria para los sensores Smart Water
#include <WaspSensorSW.h>



// define file name: MUST be 8.3 SHORT FILE NAME
char filename[]="WAPOSAT.TXT";
// define variable
uint8_t sd_answer;


char apn[] = "movistar.pe";
char login[] = "movistar@datos";
char password[] = "movistar";



int answer;

char url[150];
char urlsd[150];

unsigned int counter = 0;
// selecciona cual es la posicion del modulo wifi
uint8_t socket=SOCKET0;
uint8_t status;
//uint8_t counter=0;
char body[100];
unsigned long previous;
//se declara las vartiables para los sensores//declaramos eltiempo de hibernacion
//char hibernateTime[] = "00:00:05:00

/////////////////////////////////////
///variables ph
float value_pH;
float value_temp;
float value_pH_calculated;
////////////////////////////

float value_do;
float value_orp_calculated;
float value_orp;
float value_battery;
float value_do_calculated;
float value_temperature;

float value_cond;
float value_cond_calculated;
////////////////variablkes gps
//

////////////calibracion do
// Calibration of the sensor in normal air
#define air_calibration 2.44
// Calibration of the sensor under 0% solution
#define zero_calibration 0.09
///////////////calibracion conductividad 
// Value 1 used to calibrate the sensor
#define point1_cond 84
// Value 2 used to calibrate the sensor
#define point2_cond 1413

// Point 1 of the calibration 
#define point1_cal 10880
// Point 2 of the calibration 
#define point2_cal 728
////////////////////////////
//////////////calibracion ph
// Calibration values
#define cal_point_10 1.90
#define cal_point_7 2.02
#define cal_point_4 2.16
// Temperature at which calibration was carried out
#define cal_temp 20.23
//////////////////////
//variables para iniciar la conexion wifi
//#define ESSID "initecaruni"
//#define AUTHKEY "m53h32m53h32m"
//calibracion para los sensores
#define calibration_offset 0.001
//se crea objetos con las clases temperatura y orp y ph
pHClass pHSensor;
pt1000Class TemperatureSensor;
ORPClass ORPSensor;
DOClass DOSensor;
conductivityClass ConductivitySensor;
///declaramos eltiempo de hibernacion
char hibernateTime[] = "00:00:10:00";


/////////////////////
void setup()
{
 
    pHSensor.setCalibrationPoints(cal_point_10, cal_point_7, cal_point_4, cal_temp);
DOSensor.setCalibrationPoints(air_calibration, zero_calibration);
 ConductivitySensor.setCalibrationPoints(point1_cond, point1_cal, point2_cond, point2_cal);

     SensorSW.ON();
     // setup for Serial port over USB:
    USB.ON();
    GPRS_SIM928A.set_APN(apn, login, password);
    // And shows them
    GPRS_SIM928A.show_APN();
    USB.println(F("---******************************************************************************---"));
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
/////////////////////////
  // Powers RTC up, init I2C bus and read initial values
  USB.println(F("Init RTC"));
  RTC.ON();  
  
}

void loop()
{value_battery=PWR.getBatteryVolts();
  ////read the orp 
  value_orp = ORPSensor.readORP();
  value_temperature = TemperatureSensor.readTemperature();
  ///// Read the ph sensor
  value_pH = pHSensor.readpH();
  value_pH_calculated = pHSensor.pHConversion(value_pH,value_temp);

/*
///////////read the do sensor
value_do = DOSensor.readDO();
value_do_calculated = DOSensor.DOConversion(value_do);
////read the conductividad sensor
 value_cond = ConductivitySensor.readConductivity();
  value_cond_calculated = ConductivitySensor.conductivityConversion(value_cond);
*/

  // Apply the calibration offset
  
  char float_str_battery[10];
  dtostrf(value_battery,1,3,float_str_battery);
  value_orp_calculated = 1000*(value_orp - calibration_offset);
  char float_str_orp[10];
dtostrf( value_orp_calculated, 1, 3, float_str_orp);
char float_str_temp[10];
dtostrf( value_temperature, 1, 3, float_str_temp);
char float_str_ph[10];
dtostrf( value_pH_calculated, 1, 3, float_str_ph);
/*char float_str_do[10];
dtostrf( value_do_calculated, 1, 3, float_str_do);
char float_str_cond[10];
dtostrf( value_cond_calculated, 1, 3, float_str_cond);
*/
  
 
    
   USB.print(F("Battery Level: "));
  USB.print(value_battery,DEC);
  USB.print(F(" %"));
  
  // Show the battery Volts
  USB.print(F(" | Battery (Volts): "));
  USB.print(PWR.getBatteryVolts());
  USB.println(F(" V")); 
  
    USB.println();
    USB.print(F(" ORP aproximado: "));
    USB.print(value_orp_calculated);
    USB.println(F("mili volts"));  
    USB.print(F("Temperatura (grados centigrados ): "));
    USB.println(value_temperature);
    USB.println();
     USB.print(F("pH value: "));
  USB.print(value_pH);
  USB.print(F("volts  | "));
   USB.print(F(" pH Estimated: "));
  USB.println(value_pH_calculated);
 
 /* USB.print(F("DO Output Voltage: "));
  USB.print(value_do);
    USB.print(F(" DO Percentage: "));
  USB.println(value_orp_calculated);
  USB.print(F("Conductivity Output Resistance: "));
  USB.print(value_cond);
  USB.print(F(" Conductivity of the solution (mS/cm): "));
  USB.println(value_cond_calculated); 
*/
  snprintf(url,sizeof(url), "http://monitoreo.waposat.com/monitor/abc|123|1|%s|2|%s|4|%s|6|%s",float_str_ph,float_str_temp, float_str_orp, float_str_battery);
  snprintf(urlsd,sizeof(urlsd), "http://monitoreo.waposat.com/monitor/abc|123|1|%s|2|%s|4|%s|6|%s año:%02u mes:%02u dia:%02u hora:%02u minuto:%02u segundo:%02u  ",float_str_ph,float_str_temp, float_str_orp, float_str_battery,RTC.year,RTC.month,RTC.date,RTC.hour, RTC.minute, RTC.second);

  USB.print(F("Time [day of week, YY/MM/DD, HH:MM:SS]:"));
  USB.println(RTC.getTime());   
      
      
    sd_answer = SD.appendln(filename, urlsd);
  
  if( sd_answer == 1 )
  {
    USB.println(F("\n2 - appends \"hello\" at the end of the file"));
  }
  else 
  {
    USB.println(F("\n2 - append error"));
  }
  
  // show file
//  SD.showFile(filename);
  delay(2000);    

///////////////////////////////
    // 2. activate the GPRS_SIM928A module:
    answer = GPRS_SIM928A.ON(); 
    if ((answer == 1) || (answer == -3))
    { 
        USB.println(F("GPRS_SIM928A module ready..."));
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
        {   USB.println(F("GPRS_SIM928A module cannot connect to the network")); 
      
        }
    }
    else
    {
        USB.println(F("GPRS_SIM928A module not ready"));    
    }

      
      
}

