
object false 
  node(:sektion) {
    [{ :id => @sk.id, :name => @sk.name, :tag => @sk.uid }]
  }

  node(:notify) {
    { :title => @sk.uid, :id => @sk.id }
  }
