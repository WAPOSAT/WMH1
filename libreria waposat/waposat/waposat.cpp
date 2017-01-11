#ifndef __WPROGRAM_H__
	#include "WaspClasses.h"
#endif

#include "waposat.h"
 
waposat::waposat(){} //Constructor: no tiene que hacer nada en especial
 
void waposat::OnRelay()
{
    //Recibe un pin y un tiempo como parametros
    //Enciende y apaga el pin según el tiempo
 
    //Establecer pin como salida
    pinMode(DIGITAL6, OUTPUT);
 
    //encender
    digitalWrite(DIGITAL6,HIGH);}

void waposat::OffRelay()
{
    //Recibe un pin y un tiempo como parametros
    //Enciende y apaga el pin según el tiempo
 
    //Establecer pin como salida
    pinMode(DIGITAL6, OUTPUT);
 //apagar
    digitalWrite(DIGITAL6, LOW);
}