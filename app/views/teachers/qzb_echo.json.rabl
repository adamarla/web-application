
# This JSON initiates tabs-left formation during quiz-building

object false 
  node(:tabs) {
    @topics.map{ |m| { :name => m.name, :id => m.id } }
  } 

  node(:filters) { @filters }
  node(:context) { @context }
