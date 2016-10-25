/*  
 *  ------ GPRS_SIM928A_26 - demo GPS tracker -------- 
 *  
 *  Explanation: This example shows how use Waspmote with GPRS SIM928A module 
 *  as tracker
 *  
 *  Copyright (C) 2015 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify 
 *  it under the terms of the GNU General Public License as published by 
 *  the Free Software Foundation, either version 3 of the License, or 
 *  (at your option) any later version. 
 *  
 *  This program is distributed in the hope that it will be useful, 
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of 
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 *  GNU General Public License for more details. 
 *  
 *  You should have received a copy of the GNU General Public License 
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 *  
 *  Version:           0.1
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego 
 */


#include <WaspGPRS_SIM928A.h>
#include <WaspFrame.h>
#include <WaspSensorSW.h>
//char url[] = "http://pruebas.libelium.com/demo_sim908.php?";
char GPS_data[300];
char moteID[] = "GPRS_tracker_01";

char apn[] = "ba.amx";
char login[] = "amx";
char password[] = "amx";


int8_t answer;
int GPS_status = 0;
int GPS_FIX_status = 0;
int GPRS_status = 0;

char latitude[15], longitude[15], altitude[15], speedOG[15], courseOG[15];

//se declara las vartiables para los sensores

/////////////////////////////
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

  
void setup()

{

     pHSensor.setCalibrationPoints(cal_point_10, cal_point_7, cal_point_4, cal_temp);
DOSensor.setCalibrationPoints(air_calibration, zero_calibration);
 ConductivitySensor.setCalibrationPoints(point1_cond, point1_cal, point2_cond, point2_cal);

  
     SensorSW.ON();


    USB.println(F("**************************"));
    // 1. sets operator parameters
    GPRS_SIM928A.set_APN(apn, login, password);
    // And shows them
    GPRS_SIM928A.show_APN();
    USB.println(F("**************************")); 

    // 2. activates the 3G module:
    answer = GPRS_SIM928A.ON();
    if ((answer == 1) || (answer == -3))
    {

        USB.println(F("GPRS_SIM928A module ready..."));

        // 3. starts the GPS:
        USB.println(F("Starting in stand-alone mode")); 
        GPS_status = GPRS_SIM928A.GPS_ON();
        if (GPS_status == 1)
        { 
            USB.println(F("GPS started"));
        }
        else
        {
            USB.println(F("GPS NOT started"));   
        }

        // 4. configures connection parameters
        GPRS_SIM928A.configureGPRS_HTTP_FTP(1);

    }
    else
    {
        // Problem with the communication with the GPRS_SIM928A module
        USB.println(F("GPRS_SIM928A module not started")); 
    }
}

void loop()
{
///////////////////////////
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
  //previous=millis();
  

 
    
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

///////////////////////////
  memset(GPS_data, '\0', sizeof(GPS_data));
    // 5. checks the status of the GPS
    if (GPS_status == 1)
    {
		GPS_FIX_status = GPRS_SIM928A.waitForGPSSignal(15);
		
		if (GPS_FIX_status == 1)
		{
			answer = GPRS_SIM928A.getGPSData(1);
			Utils.setLED(LED0, LED_ON);
			if (answer == 1)
			{                
				// when it's available, shows it    
				USB.print(F("Latitude (degrees):"));
				USB.println(GPRS_SIM928A.latitude);
				USB.print(F("Longitude (degrees):"));
				USB.println(GPRS_SIM928A.longitude);
				USB.print(F("Speed over the ground"));
				USB.println(GPRS_SIM928A.speedOG);
				USB.print(F("Course over the ground:"));
				USB.println(GPRS_SIM928A.courseOG);
				USB.print(F("altitude (m):"));
				USB.println(GPRS_SIM928A.altitude);
				
				dtostrf(GPRS_SIM928A.latitude, 8 , 5, latitude);
				dtostrf(GPRS_SIM928A.longitude, 8 , 5, longitude);
				dtostrf(GPRS_SIM928A.altitude, 8 , 5, altitude);
				dtostrf(GPRS_SIM928A.speedOG, 3 , 2, speedOG);
				dtostrf(GPRS_SIM928A.courseOG, 3 , 2, courseOG);

				// 6a. add GPS data 
	/*			// add GPS position field
				snprintf(GPS_data, sizeof(GPS_data), "%svisor=false&latitude=%s&longitude=%s&altitude=%s&time=20%c%c%c%c%c%c%s&satellites=%d&speedOTG=%s&course=%s",
					url,
					latitude,
					longitude,
					altitude,
					GPRS_SIM928A.date[4], GPRS_SIM928A.date[5], GPRS_SIM928A.date[2], GPRS_SIM928A.date[3], GPRS_SIM928A.date[0], GPRS_SIM928A.date[1], GPRS_SIM928A.UTC_time,
					GPRS_SIM928A.sats_in_use,
					speedOG,
					courseOG);
	*/

				snprintf(GPS_data, sizeof(GPS_data), "http://estacion.waposat.com/Template/InsertData3.php?equipo=18&senso1=1&sensor2=2&sensor3=3&senso5=5&sensor6=6&sensor7=7&senso8=8&sensor9=9&sensor10=10&valor1=%s&valor2=%s&valor3=%s&valor4=%s&valor5=%s&valor6=%s&valor7=%s&valor8=%s&valor9=%s",
 float_str_ph,float_str_temp, float_str_do, float_str_orp, float_str_cond, float_str_battery,
latitude,
longitude,
altitude);
							
				USB.print(F("Data string: "));  
				USB.println(GPS_data);  
			}
			else
			{ 
				GPS_FIX_status = 0;
				Utils.setLED(LED0, LED_OFF);
				// 6b. add not GPS data string
				USB.println(F("GPS data not available"));  
			}
		}
		else
		{
			GPS_FIX_status = 0;
			Utils.setLED(LED0, LED_OFF);
			// 6c. add not GPS fixed string
			USB.println(F("GPS not fixed")); 		
		}
    }
    else
    {
        GPS_FIX_status = 0;
        Utils.setLED(LED0, LED_OFF);
        // 6d. add not GPS started string
        USB.println(F("GPS not started. Restarting"));
        GPS_status = GPRS_SIM928A.GPS_ON();
    }

    GPRS_status = GPRS_SIM928A.check(30);

    if((GPRS_status == 1) && (GPS_FIX_status == 1))
    {
        Utils.setLED(LED1, LED_ON);
        // 7. Sends the frame
        answer = GPRS_SIM928A.readURL(GPS_data, 1 );

        // checks the answer
        if ( answer == 1)
        {
            USB.println(F("Done"));  
            USB.println(GPRS_SIM928A.buffer_GPRS);
            Utils.setLED(LED1, LED_ON);
            delay(300);
            Utils.setLED(LED1, LED_OFF);
        }
        else 
        {
            USB.println(F("Failed"));
            Utils.setLED(LED0, LED_ON);
            delay(300);
            Utils.setLED(LED0, LED_OFF);
        } 
    }
    else if(GPRS_status == 1)
    {
        Utils.setLED(LED1, LED_ON);
        USB.println(F("GPRS connected"));
    }
    else
    {
        Utils.setLED(LED1, LED_OFF);
        USB.println(F("GPRS not connected"));
    }

}

  

