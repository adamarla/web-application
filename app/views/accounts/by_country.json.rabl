
object false
  node(:accounts) {
    @countries.map{ |c|
      a = @accounts.where(:country => c.id)
      { :name => c.name, :id => c.id, :tag => a.count, :badge => a.where{ created_at > 15.days.ago }.count }
    }
  }

