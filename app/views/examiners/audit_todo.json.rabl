
object false
  node(:audit) { 
    @questions.map{ |m| {:name => "##{@questions.index(m) + 1}", :id => m.id } }
  } 

  node(:last_pg) { @last_pg }
