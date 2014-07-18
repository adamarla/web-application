
object false 
  node(:phones) { 
    @students.map{ |j| { name: j.name, id: j.id } }
  } 
