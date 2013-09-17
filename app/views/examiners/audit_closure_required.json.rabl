
object false 
  node(:audit) { 
    @questions.map{ |m|
      { name: "#{m.topic_id}-#{m.id}", id: m.id }
    }
  } 
