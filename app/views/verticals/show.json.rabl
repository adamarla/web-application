
object false
  node(:verticals) {
    @verticals.map{ |m| { :name => m.name, :id => m.id } }
  } 
