
object false 
  node(:sektion) {
    [{ :id => @sk.id, :name => @sk.name, :tag => @sk.uid }]
  }

  node(:notify) {
    { :text => @sk.uid, :subtext => "( #{@sk.name} )" }
  }
