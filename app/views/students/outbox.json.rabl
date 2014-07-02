
object false 
  node(:outbox, if: @render) {
    @outboxed.map{ |w| { name: w.exam.quiz.name, id: w.id, badge: (w.exam.takehome ? 'icon-home' : 'icon-print') } } 
  } 
  node(:ping) { @outboxed.count }
  node(:render) { @render }
