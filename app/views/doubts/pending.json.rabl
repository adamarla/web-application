
object false 
  node(:doubts){ 
    @dbts.map{ |j| { name: j.name?, id: j.id } }
  } 
