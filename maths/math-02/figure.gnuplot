
set format "%.5f" ;
set samples 30 ; 

set table "m02_1.table" ; 
plot [x=-0.1:2.1] (2*x - x**2) ;

set parametric ; 

set trange [1.5*pi:0.5*pi] ;
set table "m02_2.table" ; 
plot 4*cos(t), 4*sin(t) ;

set table "m02_3.table" ; 
plot 2*cos(t), 2*sin(t) ;

set trange [0:2*pi] ; 
set table "m02_4.table" ; 
plot sin(3*t), cos(2*t) ;


