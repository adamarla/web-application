
object false 
  node(:tabs) { 
    @sk.map{ |m| { :id => m.id, :name => m.name, :tag => m.uid } }
  } 
