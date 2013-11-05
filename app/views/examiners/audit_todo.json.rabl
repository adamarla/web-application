
object false
  node(:audit) { 
    @questions.map{ |m| {:name => m.uid, :id => m.id } }
  } 

  node(:last_pg) { @last_pg }
