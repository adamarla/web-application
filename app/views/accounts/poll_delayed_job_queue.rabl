
object false

node(:compiled) {
  @compiled.map { |m| 
    { :id => m.id, :name => m.name }
  }
}
