
object false 

node(:questions) {
  @questions.map{ |m|
    { :question => {:name => m.uid, :id => m.id, :tag => "#{m.span_as_str}", :badge => m.marks? } }
  }
} 

node(:topic) { @topic }

