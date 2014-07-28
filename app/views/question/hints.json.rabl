
object false 
  node(:hints) {
    @hints.map{ |j| { index: j.index, text: j.text } } 
  } 
  node(:id) { @id } 
