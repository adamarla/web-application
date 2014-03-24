
object false

node(:students) { 
  @students.map{ |m| 
    { name: m.name, id: m.id }
  }
}

node(:sektion) { @sektion.id } 
node(:context) { @context.blank? ? "unknown" : @context }
node(:disabled) { @disabled }
node(:last_pg) { @last }
