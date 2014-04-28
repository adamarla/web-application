
object false 
  node(:apprentices, unless: @a.blank?){
    @a.map{ |b| { id: b.id, name: b.name } }
  }
  node(:id){ @eid }
  node(:layout){
    @q.q_selections.order(:index).map{ |x| { id: x.id, name: x.index } }
  }
