

object false 

  node(:students) {
    @students.map{ |s|
      { :student => { 
          :name => s.name, 
          :id => s.id, 
          :mean => @mean, # for the worksheet
          :max => @max, # total for the quiz 
          :marks => s.marks_scored_in(@testpaper.id),
          :graded => @answer_sheet.of_student(s.id).first.graded?,
          :tag => @answer_sheet.of_student(s.id).first.graded_thus_far_as_str, # the "a/b" bit 
          :y => @n - @students.index(s),
          :badge => @answer_sheet.of_student(s.id).first.honest?
        }
      }
    }
  }

