
object false 
  node(:inbox) {
    @ws.map { |m|
      { 
        :name => m.quiz.name, 
        :id => m.id,
        :tag => m.quiz.teacher.name
      }
    }
  } 
