
object false 
  node(:type) { :criteria }
  node(:id) { @rbid }
  node(:used) {
    @used.map{ |c| { id: c.id, name: c.text, n_stars: c.num_stars? } } 
  } 
  node(:available) {
    @available.map{ |c| { id: c.id, name: c.text, n_stars: c.num_stars? } } 
  }
