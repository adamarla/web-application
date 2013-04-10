
object false
  node(:verticals) {
    @verticals.map{ |m| { :name => m.name, :id => m.id, :tag => "#{Question.where(:topic_id => m.topic_ids).count } ques" } }
  } 
