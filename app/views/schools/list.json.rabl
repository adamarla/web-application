
object false 

node(:schools) { 
  @schools.map{ |m| 
    {
      :id => m.id, 
      :name => m.name, 
      :tag => (m.account.nil? ? "unknown" : (m.account.city.nil? ? "unknown" : m.account.city)), 
      :badge => m.contracts.nil? ? 0 : m.contracts.count
    }
  }
}

node(:last_pg) { @last_pg }

