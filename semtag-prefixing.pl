#!/usr/bin/perl -w
use utf8 ;

while (<>)

{
s/\+Actio/\+Sem\/tagactio/g ; 

s/\+Act/\+Sem\/Act/g ; 
s/\+Ani/\+Sem\/Ani/g ; 
s/\+Body/\+Sem\/Body/g ; 
s/\+Build/\+Sem\/Build/g ; 
s/\+Clth/\+Sem\/Clth/g ; 
s/\+Ctain/\+Sem\/Ctain/g ; 
s/\+Edu/\+Sem\/Edu/g ; 
s/\+Event/\+Sem\/Event/g ; 
s/\+Fem/\+Sem\/Fem/g ; 
s/\+Food/\+Sem\/Food/g ; 
s/\+Group/\+Sem\/Group/g ; 
s/\+Hum/\+Sem\/Hum/g ; 
s/\+Lang/\+Sem\/Lang/g ; 
s/\+Mal/\+Sem\/Mal/g ; 
s/\+Mat/\+Sem\/Mat/g ; 
s/\+Measr/\+Sem\/Measr/g ; 
s/\+Money/\+Sem\/Money/g ; 
s/\+Obj/\+Sem\/Obj/g ; 
s/\+Org/\+Sem\/Org/g ; 
s/\+Plant/\+Sem\/Plant/g ; 
s/\+Plc/\+Sem\/Plc/g ; 
s/\+Route/\+Sem\/Route/g ; 
s/\+Semcon/\+Sem\/Semcon/g ; 
s/\+Sur/\+Sem\/Sur/g ; 
s/\+Time/\+Sem\/Time/g ; 
s/\+Txt/\+Sem\/Txt/g ; 
s/\+Veh/\+Sem\/Veh/g ; 
s/\+Wpn/\+Sem\/Wpn/g ; 
s/\+Wthr/\+Sem\/Wthr/g ; 

s/\+Sem\/tagactio/\+Actio/g ; 

print ;
}