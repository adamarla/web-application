
object false 
  node(:tabs) { 
    @sk.values.map{ |m| { :id => m.id, :name => m.name, :tag => m.uid, :marker => @sk.key(m) } }
  } 
