
object false
  node(:typeset) {
    @new.map { |m|
      age = m.days_since_receipt
      tag = age > 0 ? "#{age} day(s) old" : "Today"
      {
        :datum => { 
          :name => m.teacher.name,
          :id => m.id,
          :tag => tag 
        }
      }
    } 
  } 
