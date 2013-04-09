
object false
  node(:questions) { 
    @questions.map{ |m|
      { :id => m.id, :name => m.uid, :tag => m.ticker? }
    }
  } 

