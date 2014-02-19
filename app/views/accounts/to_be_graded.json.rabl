
object false 
  node(:questions, unless: @sandboxed) {
    @indices.map{ |m| 
      { name: "Question ##{m.index}", id: m.id, badge: @pending.where(q_selection_id: m.id).map(&:student_id).uniq.count }
    }
  }

  node(:questions, if: @sandboxed) {
    @indices.map{ |m| 
      { name: "Question ##{m.index}", id: m.id }
    }
  }
