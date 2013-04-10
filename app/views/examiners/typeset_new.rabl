
object false
  node(:typeset) {
    @new.map { |m|
      age = m.days_since_receipt / 7
      tag = age > 0 ? "#{age} weeks" : "This week"
      {
        :name => m.teacher.name,
        :id => m.id,
        :tag => tag 
      }
    } 
  } 
