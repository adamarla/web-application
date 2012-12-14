
object false

node(:students) { 
  @students.map{ |m| 
    { :student => { :name => m.name, :id => m.id } }
  }
}

node(:sektion) { @sektion.id } 
