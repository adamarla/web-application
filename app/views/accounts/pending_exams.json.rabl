
object false
  node(:exams) {
    if @sandboxed 
      @exams.map{ |e| { id: e.id, name: e.quiz.name } }
    else
      @exams.map{ |e| { id: e.id, name: e.quiz.name, badge: e.grade_by?, tag: "#{e.percent_graded?}% done" } }
    end
  } 
  node(:ping) { @exams.count }
