
object false
  node(:exams) {
    if @sandboxed 
      @exams.map{ |e| { id: e.id, name: e.quiz.name } }
    else
      @exams.map{ |e| { id: e.id, name: e.quiz.name, badge: e.deadline?, tag: "#{e.percent_graded?}% done" } }
    end
  } 
