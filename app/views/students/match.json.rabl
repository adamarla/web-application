
object false
  node(:exists) { @exists }
  node(:enrolled) { @already } 
  node(:blocked) { @candidates.count == 0 }
  node(:candidates) {
    @candidates.map{ |m| { name: m.name, id: m.id } }
  } 
