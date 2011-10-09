
set format "%.5f" ;
set samples 30 ; 

set table "pos_root.table";
plot[0:1.5] (2*sqrt(x)) ;

set table "neg_root.table";
plot[0:1.5] (-2*sqrt(x)) ;

set parametric ;
set table "circle.table" ;
set trange [0:2*pi] ;
plot 1.5*cos(t), 1.5*sin(t) ;  
