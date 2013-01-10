
object false 
  node(:wks) { 
    @wks.map{ |m|
      { :wk => { 
          :id => m.id, 
          :name =>  m.quiz.name,
          :tag => (@who == "Student" ? m.closed_on?.strftime("%b %Y") : m.name),
          :klass => (@who == "Student" ? AnswerSheet.where(:testpaper_id => m.id, 
            :student_id => current_account.loggable_id).first.honest? : nil)
        } 
      }
    }
  } 

  node(:user) { @who }
