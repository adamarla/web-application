
object false 
  node(:inbox) {
    @exams.map { |e| { name: e.quiz.name, id: e.id, tag: e.quiz.teacher.name } }
  } 
