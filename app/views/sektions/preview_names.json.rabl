
object false
  node(:names) {
    @lines.map { |m| 
      { :name => m, :id => @lines.index(m) }
    }
  }
