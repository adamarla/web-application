
object false 
  node(:questions) {
    @indices.map{ |m| 
      { 
        name: "Question ##{m.index}", 
        id: m.id,
        badge: @pending.where(q_selection_id: m.id).map(&:student_id).uniq.count
      }
    }
  }
