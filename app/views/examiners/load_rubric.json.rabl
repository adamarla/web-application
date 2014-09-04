
object false
  node(:criteria){
    @criteria.map{ |c| { text: c.text, id: c.id, kb: c.shortcut } } 
  }

