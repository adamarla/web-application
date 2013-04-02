
object false 
  node(:topics) {
    @topics.map{ |m|
      tag = @is_admin ? "#{Question.where(:topic_id => m.id).count} ques" : nil
      { :topic => {
          :name => m.name, 
          :id => m.id,
          :tag => tag 
        }
      }
    }
  } 

  node(:disabled) { @unused }
  node(:context) { @context }
  node(:vertical) { @vertical.id }
