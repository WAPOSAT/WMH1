
#ifndef waposat_h
#define waposat_h

#include <inttypes.h>


class waposat //Definicion de la clase
{
 
    public:
 
    //Constructor de la clase
    waposat();
 
    //Funcion blinking: enciende el led 'pin', espera 'time' segundos y lo apaga
    void OnRelay();
    void OffRelay(); 
    private:
 
    //Nada que declarar
};
 
#endif
