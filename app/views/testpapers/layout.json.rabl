
object false 
  node(:tabs) {
    @subparts.map{ |m|
      {
        :tab => {:name => m.name_if_in?(@quiz.id), :id => m.id }
      }
    }
  } 
