

object false 
  node(:a) { @exam.id }  
  node(:root) { 
    @students.map{ |s| 
      id = @students.index s
      marks = @totals[id]
      {
        name: s.name, 
        id: s.id,
        tag: (marks > -1 ? "#{marks}/#{@max}" : "no scans"),
        klass: @honest[id],
        spectrum: @questions.map{ |q| @g_all.where(:student_id => s.id, :subpart_id => q.id).first.colour?},
      }
    }
  }
      
  node(:max) { @max }
  node(:totals) { @totals }
  node(:questions) {
    @questions.map{ |q| 
      { 
        name: q.name_if_in?(@exam.quiz_id),
        id: q.id
      }
    }
  } 

  node(:last_pg) { @last_pg }
