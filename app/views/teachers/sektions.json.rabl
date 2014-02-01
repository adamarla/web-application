

object false
  node(:sektions) {
    # deepdiving = (@context == 'deepdive')
    @sektions.map{ |sk|
      { id: sk.id, 
        name: sk.name, 
        badge: sk.students.count,
        tag: sk.active_period? 
      }
    }
  }
  node(:context) { @context }
