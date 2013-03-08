
object false 
  node(:sektion) { 
    [ { :new => { :id => @sk.id, :name => @sk.name, :tag => @sk.uid} } ]
  } 

  node(:tabs) { 
    [ { :id => @sk.id, :name => @sk.name, :tag => @sk.uid } ]
  } 
