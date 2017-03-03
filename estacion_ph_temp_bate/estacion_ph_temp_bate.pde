
/*  
 *  ------ estacion : ph,temperatura y bateria -------- 
 *  
 *  
 *  Version:           0.1
 *  Design:            Rubens Cortez
 *  Implementation:    Rubens Cortez
 */

//*****LIBRERIAS SMART WATER*****//
//********************************
#include <WaspSensorSW.h>
#include "WaspGPRS_SIM928A.h"
//********************************




//*****ESPECIFICACION DE OPERADOR*****//
//********************************
char apn[] = "movistar.pe";
char login[] = "movistar@datos";
char password[] = "movistar";
//********************************


//*****VARIABLES UTILES RED*****//
//********************************
int answer;
uint8_t sd_answer;
char url[150];
char urlsd[150];
unsigned int counter = 0;
//********************************

//*****VARIABLES*****//
//********************************
//--------------> ph,temperatura y bateria

float pHVol;          // ph
float temp;           // temperatura
float pHValue;        // ph
float value_battery;  // bateria
// INTENCION : enviar los datos sensados
 char float_str_battery[10];
 char float_str_temp[10];
 char float_str_ph[10];
//********************************

//*****VARIABLES CALIBRACION*****//
//********************************
// ph -volt
#define cal_point_10  1.985
#define cal_point_7   2.070
#define cal_point_4   2.227

// (ph) - temperatura
#define cal_temp 23.7
//********************************

//*****OBJETOS*****//
//********************************
pHClass pHSensor;
pt1000Class temperatureSensor;

//**********************************************************************************//
void setup()
{ 
  /////////// HABILITAR COMUNICACION SERIE
  USB.ON();
  
  //*****AJUSTE CALIBRACION*****//
  //******************************** 
  //--------------> ph
   pHSensor.setCalibrationPoints(cal_point_10, cal_point_7, cal_point_4, cal_temp);

   ////////// HABILITAR LA LECTURA DE DATOS
  Water.ON();


  //*****AJUSTE PARAMETROS DE OPERADOR*****//
  //********************************
  GPRS_SIM928A.set_APN(apn, login, password); 
  GPRS_SIM928A.show_APN();
  //********************************
   
   RTC.ON(); 
  
}
//**********************************************************************************//
void loop()
{
   // Delay
  delay(1000);  

    //*****LECTURA DE SENDORES*****//
    //********************************
    //--------------> ph,temperatura y bateria
  pHVol = pHSensor.readpH();                          // ph (voltios)
  temp = temperatureSensor.readTemperature();         // temperatura
  pHValue = pHSensor.pHConversion(pHVol, temp);       // ph (escala real)
  value_battery=PWR.getBatteryVolts();

                
 

    //*****IMPRESION EN PANTALLA*****//
    //********************************
    //--------------> ph  
  USB.print(F("pH value: "));
  USB.print(pHVol);
  USB.print(F("volts  | "));
  USB.print(F(" Temperature: "));
  USB.print(temp);
  USB.print(F("degrees  | "));  
  USB.print(F(" pH Estimated: "));
  USB.println(pHValue);
    //--------------> temperatura
  USB.print(F("Temperature (celsius degrees): "));
  USB.println(temp);
    //--------------> bateria
  USB.print(F("Battery Level: "));
  USB.print(value_battery,DEC);
  USB.print(F(" %"));
  // Show the battery Volts
  USB.print(F(" | Battery (Volts): "));
  USB.print(PWR.getBatteryVolts());
  USB.println(F(" V")); 


    //*****DE FLOAT A CADENA DE CARACTERES*****//
    //********************************
  dtostrf( temp, 1, 3, float_str_temp);
  dtostrf( pHValue, 1, 3, float_str_ph);
  dtostrf(value_battery,1,3,float_str_battery);


    
    //*****ENVIO DE DATOS AL SERVIDOR*****//
    //********************************
    snprintf(url,sizeof(url), "http://monitoreo.waposat.com/monitor/abc|123|2|%s|17|%s|6|%s",float_str_temp, float_str_ph,float_str_battery);
    // 2. activate the GPRS_SIM928A module:
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
        {   USB.println(F("GPRS_SIM928A module cannot connect to the network")); 
         
        }
    }
    else
    {
        USB.println(F("GPRS_SIM928A module not ready"));    
    }
    
    // 7. powers off the GPRS_SIM928A module
    GPRS_SIM928A.OFF();

    //*****RETARDO DEL LOOP*****//
    //********************************
   // Delay
  delay(1000);  

}
 
