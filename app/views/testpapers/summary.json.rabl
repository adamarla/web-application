

object false 
  
  node(:root) { 
    @students.map{ |s| 
      id = @students.index s
      marks = @totals[id]

      { :datum => {
          :name => s.name, 
          :id => s.id,
          :tag => (marks > -1 ? "#{marks}/#{@max}" : "no scans"),
          :klass => @honest[id],
          :spectrum => @questions.map{ |q| @g_all.where(:student_id => s.id, :subpart_id => q.id).first.colour?},
        }
      }
    }
  } 

  node(:max) { @max }
  node(:totals) { @totals }
  node(:questions) {
    @questions.map{ |q| 
      { 
        :name => q.name_if_in?(@ws.quiz_id),
        :id => q.id
      }
    }
  } 
