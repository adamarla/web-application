
object false 
  node(:disputes){
    @g.map{ |a| { name: a.name?, id: a.id, badge: a.marks?, klass: a.perception? } }
  }
