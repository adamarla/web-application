
object false 
  node(:wks) {
    @worksheets.map{ |m|
      {:id => m.id, :name => m.quiz.name, :tag => m.name } 
    }
  } 
