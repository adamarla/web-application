

object false
  node(:sektions) {
    deepdiving = (@context == 'deepdive')
    @sektions.map{ |sk|
      {
        :sektion => {
          :id => sk.id,
          :name => sk.label,
          :tag => "#{deepdiving ? "#{sk.students.count} student(s)" : "#{sk.uid}" }"
        }
      }
    }
  }
  node(:context) { @context }
