
object false 
  node(:disputes){
    @g.map{ |a| { name: "##{@g.index(a) + 1}", id: a.id, badge: a.marks?, klass: a.honest? } }
  }
