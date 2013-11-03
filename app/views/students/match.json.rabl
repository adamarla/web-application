
object false
  node(:exists) { @exists }
  node(:enrolled) { @enrolled } 
  node(:blocked) { @candidates.count == 0 }
  node(:candidates) {
    @candidates.map{ |m| { :name => m.name, :id => m.account.id } }
  } 
