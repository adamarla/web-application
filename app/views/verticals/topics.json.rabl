
object false 
  node(:topics) {
    @topics.map{ |m|
      if @show_n
        q = Question.where(topic_id: m.id)
        n = @eid.nil? ? q.count : q.where(examiner_id: @eid).count  
        tag = "#{n} ques" 
      else 
        tag = nil
      end 
      { name: m.name, id: m.id, tag: tag }
    }
  } 

  node(:disabled) { @unused }
  node(:context) { @context }
  node(:vertical) { @vertical.id }
