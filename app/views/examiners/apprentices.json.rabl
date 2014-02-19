
object false 
  node(:apprentices) {
    @apprentices.map{ |a| {name: a.name, id: a.id } }
  }
