
# Output Example : 
#  {"schools":[{"school":{"name":"AFBBS"}},{"school":{"name":"DPS"}}]

object false 
  node(:schools) { 
    @schools.map{ |m| 
      { :school => { :id => m.id, :name => m.name, :tag => m.city } }
    }
  }
  node(:last_pg) { @last_pg }
