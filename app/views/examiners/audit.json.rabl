
object false
  node(:audit) { 
    @questions.map{ |m| {:name => "##{@questions.index(m) + 1}", :id => m.id } }
  } 
