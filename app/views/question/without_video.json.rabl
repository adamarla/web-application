
object false
  node(:unwatchable) {
    @questions.map { |m| 
      { name: "#{m.topic_id}-#{m.id}",
        id: m.id,
        tag: "#{m.topic.name}" }
    }
  } 
