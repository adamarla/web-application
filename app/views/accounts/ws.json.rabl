
object false 
  node(:wks) { 
    @wks.map{ |m|
      { :wk => { 
          :id => m.id, 
          :name =>  m.quiz.name,
          :tag => (@who == "Student" ? m.closed_on?.strftime("%b %Y") : m.name)
        } 
      }
    }
  } 

  node(:who) { @who }
