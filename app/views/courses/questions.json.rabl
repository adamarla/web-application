
object false 

node(:questions) {
  @questions.map{ |m|
    { :question => {:name => m.uid, :id => m.id, :tag => "#{m.length?} pg(s)", :badge => m.marks? } }
  }
} 

node(:topic) { @topic }

