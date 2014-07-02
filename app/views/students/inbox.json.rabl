
object false 
  node(:inbox, if: @render) {
    @inboxed.map{ |w| { name: w.exam.quiz.name, id: w.id, badge: 'icon-home' } }
  } 
  node(:ping) { @inboxed.count }
  node(:render) { @render }
