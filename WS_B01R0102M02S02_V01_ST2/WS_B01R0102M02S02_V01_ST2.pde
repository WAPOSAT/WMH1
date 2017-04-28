/*
 *  --- [B01R01M02H02] - V0.2  ----
 *  Explicacion: La estacion utiliza una placa SmartWater para lectura de sensores,
 *  una tarjeta GPRS y GPS para la conexion con el servidor remoto, utiliza una 
 *  memoria MicroSD para el registro de la actividad de manera local y ingresa a
 *  un estado de hibernacion para ahorro de energia.
 *  
 *  Copyright (C) 2017 Waposat Development
 *  
 *  Debes configurar los parametros que deseas comunicar incluidos la bateria
 *  Debes configurar el tiempo de hibernacion en la variable hibernateTime[]
 *  la informacion local es almacenada en el archivo LOG.TXT
 *  
 *  Diseñado:       Victor Hilario
 *  Implementado:   Juan Basilio
 */

#include "WaspGPRS_SIM928A.h"
#include <WaspWIFI.h>
//incluye libreria para los sensores Smart Water
#include <WaspSensorSW.h>


// Variables para la MicroSD
// define file name: MUST be 8.3 SHORT FILE NAME
char filename[]="LOG.TXT";
// respuesta de las operaciones con el MicroSD
uint8_t sd_answer;
int8_t fileFound;
char urlsd[150];
// Fin de variables para la MicroSD


// Variables para el GPRS
int answer;
char url[150];
unsigned int counter = 0;

// Asignar un APN
// --- APN CLARO ---- //
char apn[] = "claro.pe";
char login[] = "claro";
char password[] = "claro";
// --- APN MOVISTAR --- //
/*
char apn[] = "movistar.pe";
char login[] = "movistar@datos";
char password[] = "movistar";
*/
// Fin de variables para el GPRS


// Variables para los sensores
float value_pH;
float value_pH_calculated;
float value_do;
float value_do_calculated;
float value_orp;
float value_orp_calculated;
float value_cond;
float value_cond_calculated;
float value_battery;
float value_temp;
float value_temperature;
// Fin de variables para los sensores

// Definicion de los puntos de calibracion

// Sensor de Disolucion de Oxigeno
// Calibration of the sensor in normal air
#define air_calibration 1.17
// Calibration of the sensor under 0% solution
#define zero_calibration 0.0

// Sensor de Conductividad Electrica
// Value 1 used to calibrate the sensor
#define point1_cond 84
// Value 2 used to calibrate the sensor
#define point2_cond 1413

// Point 1 of the calibration 
#define point1_cal 8678.00
// Point 2 of the calibration 
#define point2_cal 890.50

// Sensor de pH
// Calibration values
#define cal_point_10 2.03838
#define cal_point_7 2.112844
#define cal_point_4 2.20901
// Temperature at which calibration was carried out
#define cal_temp 30.0

// Sensor de Potencial Redox
#define calibration_offset 0.001

// Fin de definicion de los puntos de calibracion


// Creacion de los objetos para SmartWater
pHClass pHSensor;
pt1000Class TemperatureSensor;
ORPClass ORPSensor;
DOClass DOSensor;
conductivityClass ConductivitySensor;
// FIn de creacion de objetos para SmartWater


///declaramos eltiempo de hibernacion
char deepSleepTime[] = "00:00:01:00";



void setup(){ 
  PWR.ifHibernate();

  Water.ON();
  //SensorSW.ON(); // Para IDE anterior
  
  // Inicializa un puerto USB
  USB.ON();
  USB.println(F("USB port started..."));
  
  // Configuracion del APN
  GPRS_SIM928A.set_APN(apn, login, password);
  // And shows them
  GPRS_SIM928A.show_APN();

  // Incializa el reloj interno
  USB.println(F("---******************************************************************************---"));
  USB.println(F("Init RTC"));
  RTC.ON();  

  // Inicializa la MicroSD
  USB.println(F("Iniciando SD..."));
  SD.ON();
  SD.ls(LS_SIZE);
  fileFound = SD.isFile(filename);
  if(fileFound!=1){
    USB.println(F("No se ha encontrado a log..."));  
    USB.println(F("Creando el archivo log"));
    sd_answer = SD.create(filename);
    if( sd_answer == 1 ){
      USB.println(F("Archivo creado"));
    }
    else {
      USB.println(F("No se pudo crear el archivo"));  
    }
  } 

  // Ingresan los valores de calibracion
  pHSensor.setCalibrationPoints(cal_point_10, cal_point_7, cal_point_4, cal_temp);
  DOSensor.setCalibrationPoints(air_calibration, zero_calibration);
  ConductivitySensor.setCalibrationPoints(point1_cond, point1_cal, point2_cond, point2_cal);
    
}

void loop(){
  
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
  
  //USB.println();
  //USB.print(F(" ORP aproximado: "));
  //USB.print(value_orp_calculated);
  //USB.println(F("mili volts"));  
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

  RTC.getTime();
  
  //snprintf(url,sizeof(url), "http://monitoreo.waposat.com/monitor/abc|123|10|%s|18|%s|7|%s",float_str_temp, float_str_ph, float_str_phres);
  //snprintf(url,sizeof(url), "http://monitoreo.waposat.com/monitor/abc|123|2|%s|6|%s",float_str_temp, float_str_battery);
  snprintf(url,sizeof(url), "http://monitoreo.waposat.com/monitor/abc|123|20|%s|19|%s|22|%s|23|%s",float_str_temp, float_str_ph, float_str_cond, float_str_battery);
  snprintf(urlsd,sizeof(urlsd), "http://monitoreo.waposat.com/monitor/abc|123|1|%02u%02u%02u%02u%02u%02u|20|%s|19|%s|22|%s|23|%s",RTC.year,RTC.month,RTC.date,RTC.hour, RTC.minute, RTC.second,float_str_temp, float_str_ph, float_str_cond, float_str_battery);
    
    // 2. activate the GPRS_SIM928A module:
    answer = GPRS_SIM928A.ON(); 
    if ((answer == 1) || (answer == -3)){
       
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

    //          sprintf(url, "http://monitoreo.waposat.com/monitor/abc|123|1|%s|2|%s|3|%s", float_str_temp, float_str_orp,float_str_battery);
//snprintf(url,sizeof(url), "http://monitoreo.waposat.com/monitor/abc|123|1|%s|2|%s|3|%s|4|%s|5|%s|6|%s",float_str_ph,float_str_temp, float_str_do, float_str_orp, float_str_cond, float_str_battery);
             
             
              USB.println(F("-------------------------------------------"));
              USB.println(url);                
              USB.println(F("-------------------------------------------"));
              sd_answer = SD.appendln(filename, urlsd);
              if( sd_answer == 1 ){
                USB.println(F("Se ha guardado en la memoria..."));
              }else {
                USB.println(F("no se ha podido guardar en la memoria"));
                sd_answer = SD.appendln(filename, "No se ha podido guardar un registro.");
              }

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
              }
              */
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
    else{
        USB.println(F("GPRS_SIM928A module not ready"));    
    }
    
    // 7. powers off the GPRS_SIM928A module
    GPRS_SIM928A.OFF(); 
    USB.println(F("GPRS OFF"));
  //  counter++;

    USB.println(F("Ingresando a Deep Sleep"));
    sd_answer = SD.appendln(filename, "Ingresando a Deep Sleep ...");
    PWR.deepSleep(deepSleepTime,RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);
    delay(100);

    // Verificando si hubo un Deep Sleep previo
    if( intFlag & RTC_INT ){
        clearFlag();
    }
      
}

void clearFlag()
{
    // clear interruption flag
    intFlag &= ~(RTC_INT);
    
    USB.println(F("---------------------"));
    USB.println(F("RTC INT captured"));
    USB.println(F("---------------------"));
    Utils.blinkLEDs(300);
    Utils.blinkLEDs(300);
    Utils.blinkLEDs(300);
}
