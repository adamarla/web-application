
object false 
  node(:disputes){
    @g.map{ |a| { name: "Ques. #{a.name?}", id: a.id, badge: a.marks?, klass: a.honest? } }
  }
