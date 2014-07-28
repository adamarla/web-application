
object false 
  node(:subparts) { 
    @subparts.map{ |j| { id: j.id, index: j.index } } 
  } 
  node(:context) { @context }
