 #include "WaspGPRS_SIM928A.h"
#include <WaspWIFI.h>
//incluye libreria para los sensores Smart Water
#include <WaspSensorSW.h>

char apn[] = "claro.pe";
char login[] = "claro";
char password[] = "claro";
//////////////variables sd

// define file name: MUST be 8.3 SHORT FILE NAME
char filename[]="FILE2.TXT";
// define hexadecimal data
uint8_t data[10]={0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0xAA,0xAA};
// define variable
uint8_t sd_answer;
int i=0;

/////////////////////////////
///variables ph
float value_pH;
float value_temp;
float value_pH_calculated;
////////////////////////////
//int answer;
int8_t answer, x, y;
int8_t GPS_status = 0;
char url[150];
unsigned int counter = 0;
// selecciona cual es la posicion del modulo wifi
uint8_t socket=SOCKET0;
uint8_t status;
//uint8_t counter=0;
char body[100];
unsigned long previous;
//se declara las vartiables para los sensores
float value_do;
float value_orp_calculated;
float value_orp;
float value_battery;
float value_do_calculated;
float value_temperature;

float value_cond;
float value_cond_calculated;
////////////////variablkes gps
float altitud,latitud,longitud,hora;


////////////calibracion do
// Calibration of the sensor in normal air
#define air_calibration 2.65
// Calibration of the sensor under 0% solution
#define zero_calibration 0.0
///////////////calibracion conductividad 
// Value 1 used to calibrate the sensor
#define point1_cond 10500
// Value 2 used to calibrate the sensor
#define point2_cond 40000

// Point 1 of the calibration 
#define point1_cal 197.00
// Point 2 of the calibration 
#define point2_cal 150.00
////////////////////////////
//////////////calibracion ph
// Calibration values
#define cal_point_10 1.9022590637
#define cal_point_7 2.0336668491
#define cal_point_4 2.1262030601
// Temperature at which calibration was carried out
#define cal_temp 23.7
//////////////////////
//variables para iniciar la conexion wifi
//#define ESSID "initecaruni"
//#define AUTHKEY "m53h32m53h32m"
//calibracion para los sensores
#define calibration_offset 0.0
//se crea objetos con las clases temperatura y orp y ph
pHClass pHSensor;
pt1000Class TemperatureSensor;
ORPClass ORPSensor;
DOClass DOSensor;
conductivityClass ConductivitySensor;
// el host y la url
//char HOST[] = "estacion.waposat.com";
//char URL[]  = "GET$/Template/InsertData3.php?";
///declaramos eltiempo de hibernacion
//char hibernateTime[] = "00:00:05:00";


void setup()
{  
  
   pHSensor.setCalibrationPoints(cal_point_10, cal_point_7, cal_point_4, cal_temp);
  
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
////////////////////////////
// 1. activates the GPRS_SIM928A module:
    answer = GPRS_SIM928A.ON();
    if ((answer == 1) || (answer == -3))
    {

        USB.println(F("GPRS_SIM928A module ready..."));

        // 2. starts the GPS in MS-based mode:
        USB.println(F("Starting in stand-alone mode")); 
        GPS_status = GPRS_SIM928A.GPS_ON();
        if (GPS_status == 1)
        { 
            USB.println(F("GPS started"));
            // 3. waits to fix satellites
            GPRS_SIM928A.waitForGPSSignal(30);
        }
        else
        {
            USB.println(F("GPS NOT started"));   
        }
    }
    else
    {
        // Problem with the communication with the GPRS_SIM928A module
        USB.println(F("GPRS_SIM928A module not started")); 
    }
    
    /////////////////////////////////////////
    // 1. sets operator parameters
    GPRS_SIM928A.set_APN(apn, login, password);
    // And shows them
    GPRS_SIM928A.show_APN();
    USB.println(F("---******************************************************************************---"));
DOSensor.setCalibrationPoints(air_calibration, zero_calibration);
 ConductivitySensor.setCalibrationPoints(point1_cond, point1_cal, point2_cond, point2_cal);

///////////////////////////////////////////////////////////
 SD.ON();
    
  // Delete file
  sd_answer = SD.del(filename);
  
  if( sd_answer == 1 )
  {
    USB.println(F("file deleted"));
  }
  else 
  {
    USB.println(F("file NOT deleted"));  
  }
    
  // Create file
  sd_answer = SD.create(filename);
  
  if( sd_answer == 1 )
  {
    USB.println(F("file created"));
  }
  else 
  {
    USB.println(F("file NOT created"));  
  } 
  ////////////////////////////////////////
}

void loop()
{
  
    /////gps
  if ((GPS_status == 1) && (GPRS_SIM928A.waitForGPSSignal(30) == 1))
    {
        // 5. reads GPS data
        answer = GPRS_SIM928A.getGPSData(1);

        if (answer == 1)
        {
          //////////////////////gps
            latitud=GPRS_SIM928A.latitude;
            longitud=GPRS_SIM928A.longitude;
          hora =199;  //hora=GPRS_SIM928A.UTC_time;
            altitud=GPRS_SIM928A.altitude;
  ////////////////////
            // 6. Shows all GPS data collected          
            USB.print(F("Latitude (in degrees): "));
            USB.print(latitud);
            USB.print(F("\t\tLongitude (in degrees): "));
            USB.println(longitud);
            USB.print(F("Date: "));
            USB.print(GPRS_SIM928A.date);
            USB.print(F("\t\tUTC_time: "));
            USB.println(GPRS_SIM928A.UTC_time);
            USB.print(F("Altitude: "));
            USB.print(altitud);
            USB.print(F("\t\tSpeedOG: "));
            USB.print(GPRS_SIM928A.speedOG);
            USB.print(F("\t\tCourse: "));
            USB.println(GPRS_SIM928A.courseOG);
            USB.print(F("\t\tSatellites in use: "));
            USB.println(GPRS_SIM928A.sats_in_use, DEC);
            USB.print(F("\t\tSatellites in view: "));
            USB.println(GPRS_SIM928A.sats_in_use, DEC); 
    
            USB.print("PDOP: ");
            USB.print(GPRS_SIM928A.PDOP);
            USB.print("\t\tHDOP: ");
            USB.print(GPRS_SIM928A.HDOP);
            USB.print("\t\tVDOP: ");
            USB.print(GPRS_SIM928A.VDOP);
            USB.print("\t\tSNR: ");
            USB.println(GPRS_SIM928A.SNR, DEC);
    
            
            USB.println("");
        }    
    }
    else
    {
        USB.println(F("GPS not started"));  
        delay(10000);      
    }
    /////////////////////////////////////
    
    //////////////////////////
value_battery=PWR.getBatteryVolts();
  ////read the orp 
  value_orp = ORPSensor.readORP();
  value_temperature = TemperatureSensor.readTemperature();
  ///// Read the ph sensor
  value_pH = pHSensor.readpH();
  value_pH_calculated = pHSensor.pHConversion(value_pH,value_temp);
///////////read the do sensor
value_do = DOSensor.readDO();
value_do_calculated = DOSensor.DOConversion(value_do);
////read the conductividad sensor
 value_cond = ConductivitySensor.readConductivity();
  value_cond_calculated = ConductivitySensor.conductivityConversion(value_cond);


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
char float_str_do[10];
dtostrf( value_do_calculated, 1, 3, float_str_do);
char float_str_cond[10];
dtostrf( value_cond_calculated, 1, 3, float_str_cond);
char float_str_latitud[10];
dtostrf(latitud, 1, 3, float_str_latitud);
char float_str_longitud[10];
dtostrf(longitud, 1, 3, float_str_longitud);
char float_str_altitud[10];
dtostrf(altitud, 1, 3, float_str_altitud);
char float_str_hora[10];
dtostrf(hora, 1, 3, float_str_hora);

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
  USB.print(F("DO Output Voltage: "));
  USB.print(value_do);
    USB.print(F(" DO Percentage: "));
  USB.println(value_orp_calculated);
  USB.print(F("Conductivity Output Resistance: "));
  USB.print(value_cond);
  USB.print(F(" Conductivity of the solution (mS/cm): "));
  USB.println(value_cond_calculated); 
  
   sprintf(url, "http://estacion.waposat.com/Template/InsertData3.php?equipo=18&sensor1=2&sensor2=5&sensor3=7&sensor4=8&sensor5=9&sensor6=10&sensor7=11&sensor8=12&sensor9=13&valor1=%s&valor2=%s&valor3=%s&valor4=%s&valor5=%s&valor6=%s&valor7=%s&valor8=%s&valor9=%s&valor10=%s", float_str_temp, float_str_orp, float_str_battery, float_str_ph, float_str_do,float_str_cond, float_str_latitud, float_str_longitud, float_str_altitud);

  
  //////////////////////////////////////
//////////////////////////
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

////////////////sprintf(url, "http://estacion.waposat.com/Template/InsertData3.php?equipo=18&sensor1=2&sensor2=5&sensor3=7&sensor4=8&sensor5=9&sensor6=10&sensor7=11&sensor8=12&sensor9=13&valor1=%s&valor2=%s&valor3=%s&valor4=%s&valor5=%s&valor6=%s&valor7=%s&valor8=%s&valor9=%s&valor10=%s", float_str_temp, float_str_orp, float_str_battery, float_str_ph, float_str_do,float_str_cond, float_str_latitud, float_str_longitud, float_str_altitud);

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
  
    // 1 - It writes “hello” in file at position 0    
  sd_answer = SD.writeSD(filename,url, i);
  
  if( sd_answer == 1 ) 
  {
    i=i+1;
    USB.println(F("\n1 - Write \"url\" in file at position 0 ")); 
  }
  else
  {
    USB.println(F("\n1 - Write failed"));  
  }
  
  // show file
  SD.showFile(filename);
  delay(1000);
  
}

