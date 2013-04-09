
object false
  node(:wks) { 
    @wks.map{ |m| { :id => m.id, :name => m.quiz.name, :tag => m.name } }
  } 
