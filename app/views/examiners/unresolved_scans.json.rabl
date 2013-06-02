
object false
  node(:unresolved) { 
    @scans.map{ |m| {:name => "##{@scans.index(m) + 1}", :id => m } }
  } 
