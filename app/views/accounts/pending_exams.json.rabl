
object false
  node(:exams) { 
    @exams.map{ |e| { id: e.id, name: e.quiz.name, badge: e.deadline?, tag: "#{e.percent_graded?}% done" } }
  } 
