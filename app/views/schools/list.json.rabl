
object false 

node(:schools) { 
  @schools.map{ |m| 
    {
      :id => m.id, 
      :name => m.name, 
      :tag => (m.account.nil? ? "unknown" : (m.account.city.nil? ? "unknown" : m.account.city)), 
      :badge => (m.account.nil? ? 0 : (m.account.customer.nil? ? 0 : m.account.customer.contracts.count ))
    }
  }
}

node(:last_pg) { @last_pg }

