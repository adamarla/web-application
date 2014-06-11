
object false 
  node(:rubrics) {
    @rb.map{ |r| { name: r.name, id: r.id } } 
  }
