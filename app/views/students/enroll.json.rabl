
object false
  node(:block) { @candidates.count == 0 }
  node(:candidates, :if => lambda{ |m| @candidates.count > 0 }) {
    @candidates.map{ |m| { :name => m.name, :id => m.account.id } }
  } 
