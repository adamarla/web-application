
object false 
  node(:outbox) {
    @outboxed.map{ |w| { name: w.exam.quiz.name, id: w.id, badge: (w.exam.takehome ? 'icon-home' : 'icon-print') } } 
  } 
