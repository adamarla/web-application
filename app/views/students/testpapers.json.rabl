
object false
  node(:wrks) {
    @publishable.map{ |m|
      { :id => m.id, :name => m.quiz.name, :tag => m.closed_on?.strftime('%b '%d, '%Y') }  
    }
  }

