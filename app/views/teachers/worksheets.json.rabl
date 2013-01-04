
object false 
  node(:wks) {
    @worksheets.map{ |m|
      { :wk => {:id => m.id, :name => m.quiz.name, :tag => m.name } }
    }
  } 
