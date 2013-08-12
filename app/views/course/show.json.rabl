
object false
  node(:courses) {
    @courses.map{ |c|
      {
        id: c.id,
        name: c.name,
        tag: "$ #{c.price.to_f}"
      }
    }
  } 
  
