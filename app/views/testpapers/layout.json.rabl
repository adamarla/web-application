
object false 
  node(:tabs) {
    @subparts.map{ |m| 
      {
        :name => m.name_if_in?(@quiz.id), 
        :id => @gr.where(:subpart_id => m.id).map(&:id).first 
      } 
    } 
  } 

  node(:user) { @who }
