
object false
  node(:ongoing) { 
    @ongoing.map{ |m| 
      { :tag => m.teacher.name, 
        :id => m.id, 
        :name => m.created_at.strftime("%b %d, %Y") }
    }
  } 
