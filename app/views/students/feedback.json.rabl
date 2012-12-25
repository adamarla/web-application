
object false
  node(:tabs) {
    @r.map { |m|
      { :name => m.name?, :id => m.id  }
    }
  } 
