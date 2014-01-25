

object false
  node(:sektions) {
    deepdiving = (@context == 'deepdive')
    @sektions.map{ |sk|
      { id: sk.id, name: sk.name?, tag: "#{deepdiving ? "#{sk.students.count} student(s)" : "#{sk.uid}" }" }
    }
  }
  node(:context) { @context }
