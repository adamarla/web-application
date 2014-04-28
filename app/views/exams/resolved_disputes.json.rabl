

object false 
  node(:resolved) {
    @g.map{ |a| 
      { name: "#{a.student.name} - #{a.name?}", id: a.id, badge: a.marks?, tag: a.examiner.first_name }
    }
  }
  node(:last_pg){ @last } 
