
object false 
  node(:inbox) {
    @inboxed.map{ |w| { name: w.exam.quiz.name, id: w.id, badge: 'icon-home' } }
  } 
