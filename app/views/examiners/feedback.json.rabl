
object false
  node(:rqms) {
    @r.map{ |m|
      { :id => m.id, :name => m.text, :long => m.bottomline }
    }
  }
