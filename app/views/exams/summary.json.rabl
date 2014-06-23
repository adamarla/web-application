

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
        klass: @perceptions[id],
        spectrum: @exam.spectrum?(s.id) 
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
