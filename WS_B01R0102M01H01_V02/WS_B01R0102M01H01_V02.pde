//////// el titulo alli esta el secreto 
//disolucion de oxigeno
//conductividad
//temperatura 
//ph
//potencial redox
//cloro residual 
// turbiedad
// bateria 



#include "WaspGPRS_SIM928A.h"
#include <WaspWIFI.h>
//incluye libreria para los sensores Smart Water
#include <WaspSensorSW.h>



// define file name: MUST be 8.3 SHORT FILE NAME
char filename[]="WAPOSAT.TXT";
// define variable
uint8_t sd_answer;
/*
char apn[] = "claro.pe";
char login[] = "claro";
char password[] = "claro";
*/

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
#define point1_cal 8215.00
// Point 2 of the calibration 
#define point2_cal 796.00
////////////////////////////


//////////////calibracion ph
// Calibration values
#define cal_point_10 2.023
#define cal_point_7 2.103
#define cal_point_4 2.235
// Temperature at which calibration was carried out
#define cal_temp 18.0


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
//char hibernateTime[] = "00:00:01:00";


/////////////////////
void setup()
{ // PWR.ifHibernate();
 
 
 pHSensor.setCalibrationPoints(cal_point_10, cal_point_7, cal_point_4, cal_temp);
 DOSensor.setCalibrationPoints(air_calibration, zero_calibration);
 ConductivitySensor.setCalibrationPoints(point1_cond, point1_cal, point2_cond, point2_cal);

     //SensorSW.ON();
     Water.ON();
     // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));
    /*
    USB.println(F("---******************************************************************************---"));
    USB.println(F("GET request to the libelium's test url..."));
    USB.println(F("You can use this php to test the HTTP connection of the module."));
    USB.println(F("The php returns the parameters that the user sends with the URL."));
    USB.println(F("In this case the loop counter (counter) and the RTC temperature (temp)."));
    USB.println(F("The syntax to add parameters is below:"));
    USB.println(F("getpost_frame_parser.php?parameter1=value1&parameter2=value2&...&last_parameter=last_value"));
    USB.println(F("---******************************************************************************---"));
    */
    // 1. sets operator parameters
    GPRS_SIM928A.set_APN(apn, login, password);
    // And shows them
    GPRS_SIM928A.show_APN();
    USB.println(F("---******************************************************************************---"));
     USB.println(F("Init RTC"));
  RTC.ON();  
  
}

void loop()
{
  ////////////////////////
///////////////////////////
  value_battery=PWR.getBatteryVolts();
  ////read the orp 
  //value_orp = ORPSensor.readORP();
  value_temperature = TemperatureSensor.readTemperature();
  ///// Read the ph sensor
  value_pH = pHSensor.readpH();
  value_pH_calculated = pHSensor.pHConversion(value_pH,value_temperature);
  ///////////read the do sensor
  //value_do = DOSensor.readDO();
  //value_do_calculated = DOSensor.DOConversion(value_do);
  //read the conductividad sensor
  value_cond = ConductivitySensor.readConductivity();
  value_cond_calculated = ConductivitySensor.conductivityConversion(value_cond);


  // Apply the calibration offset
  
  char float_str_battery[10];
  dtostrf(value_battery,1,3,float_str_battery);
  //value_orp_calculated = 1000*(value_orp - calibration_offset);
  //char float_str_orp[10];
  //dtostrf( value_orp_calculated, 1, 3, float_str_orp);
  char float_str_temp[10];
  dtostrf( value_temperature, 1, 3, float_str_temp);
  char float_str_ph[10];
  char float_str_phres[10];
  dtostrf( value_pH, 1, 4, float_str_phres);
  dtostrf( value_pH_calculated, 1, 3, float_str_ph);
  //char float_str_do[10];
  //dtostrf( value_do_calculated, 1, 3, float_str_do);
  char float_str_cond[10];
  dtostrf( value_cond_calculated, 1, 3, float_str_cond);
  //char float_str_cond_resist[10];
  //dtostrf( value_cond, 1, 3, float_str_cond_resist);
    
  USB.print(F("Battery Level: "));
  USB.print(PWR.getBatteryLevel(),DEC);
  USB.print(F(" %"));
  
  // Show the battery Volts
  USB.print(F(" | Battery (Volts): "));
  USB.print(PWR.getBatteryVolts());
  USB.println(F(" V")); 
  
//  USB.println();
//  USB.print(F(" ORP aproximado: "));
//  USB.print(value_orp_calculated);
//  USB.println(F("mili volts"));  
  USB.print(F("Temperatura (grados centigrados ): "));
  USB.println(value_temperature);
  USB.println();
  USB.print(F("pH value: "));
  USB.print(value_pH);
  USB.print(F("volts  | "));
  USB.print(F(" pH Estimated: "));
  USB.println(value_pH_calculated);
 // USB.println(float_str_ph);
//  USB.print(F("DO Output Voltage: "));
//  USB.print(value_do);
//  USB.print(F(" DO Percentage: "));
//  USB.println(value_orp_calculated);
  USB.print(F("Conductivity Output Resistance: "));
  USB.print(value_cond);
 USB.print(F(" Conductivity of the solution (mS/cm): "));
 USB.println(value_cond_calculated); 

    //snprintf(url,sizeof(url), "http://monitoreo.waposat.com/monitor/abc|123|10|%s|18|%s|7|%s",float_str_temp, float_str_ph, float_str_phres);
    snprintf(url,sizeof(url), "http://monitoreo.waposat.com/monitor/abc|123|10|%s|18|%s|5|%s|21|%s",float_str_temp, float_str_ph, float_str_cond, float_str_battery);
  //snprintf(url,sizeof(url), "http://monitoreo.waposat.com/monitor/abc|123|2|%s|6|%s",float_str_temp, float_str_battery);
    
    // 2. activate the GPRS_SIM928A module:
    answer = GPRS_SIM928A.ON(); 
    if ((answer == 1) || (answer == -3))
    { 
        USB.println(F("GPRS_SIM928A module ready..."));

        // 4. wait for connection to the network:
        answer = GPRS_SIM928A.check(60);    
        if (answer == 1)
        {             
            USB.println(F("GPRS_SIM928A module connected to the network..."));

            // 5. configures GPRS connection for HTTP or FTP applications:
            answer = GPRS_SIM928A.configureGPRS_HTTP_FTP(1);
            if (answer == 1)
            {
                USB.println(F("Get the URL with GET request..."));          
                RTC.ON();

                //sprintf(url, "http://monitoreo.waposat.com/monitor/abc|123|1|%s|2|%s|3|%s", float_str_temp, float_str_orp,float_str_battery);
                //snprintf(url,sizeof(url), "http://monitoreo.waposat.com/monitor/abc|123|1|%s|2|%s|3|%s|4|%s|5|%s|6|%s",float_str_ph,float_str_temp, float_str_do, float_str_orp, float_str_cond, float_str_battery);
               
               
                USB.println(F("-------------------------------------------"));
                USB.println(url);                
                USB.println(F("-------------------------------------------"));

                // 6. gets URL from the solicited URL
                answer = GPRS_SIM928A.readURL(url, 1);
                /*
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
                }*/

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
    
    // 7. powers off the GPRS_SIM928A module
    GPRS_SIM928A.OFF(); 

  //  counter++;


    delay(100);

}
