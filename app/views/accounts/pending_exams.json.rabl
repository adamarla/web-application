
object false
  node(:exams) { 
    @exams.map{ |m| { :id => m.id, :name => m.quiz.name, :tag => m.name } }
  } 
