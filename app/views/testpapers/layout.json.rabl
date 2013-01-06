
object false 
  node(:tabs) {
    @subparts.map{ |m| {:name => m.name_if_in?(@quiz.id), :id => m.id } }
  } 

  node(:user) { @who }
