

object false
  node(:sektions) {
    @sektions.map{ |sk|
      { id: sk.id, 
        name: sk.name, 
        badge: sk.students.count,
        tag: (@indie ? sk.active_period? : sk.uid)
      }
    }
  }
  node(:context) { @context }
