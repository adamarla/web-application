
object false
  node(:courses) {
    @courses.map{ |c| { id: c.id, name: c.title } }
  } 
  
