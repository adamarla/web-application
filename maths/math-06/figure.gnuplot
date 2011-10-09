
set format "%.5f" ;
set samples 30 ; 

set parametric ;
set table "circle.table" ;
set trange [0:2*pi] ;
plot cos(t), sin(t) ;  
