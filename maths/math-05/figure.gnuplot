
set format "%.5f" ;
set samples 30 ; 

set table "l1.table" ; 
plot [0.5:-1.5] (-1-x) ;                                                                                                               
set table "l2.table" ;
plot [-0.5:1.5] (x-1) ;

set table "l3.table" ;
plot [0.5:-1.5] (1+x) ;

set table "l4.table" ;
plot [-0.5:1.5] (1-x) ;

