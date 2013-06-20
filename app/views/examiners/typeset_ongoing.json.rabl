
object false
  node(:ongoing) { 
    @ongoing.map{ |m| 
      { :name => m.teacher.name, :id => m.id, :tag => (Date.today - m.created_at.to_date).to_i }
    }
  } 
