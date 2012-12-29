
object false 

node(:quizzes) { 
  @quizzes.map{ |n|
    {
      :quiz => {
        :name => n.name,
        :id => n.id,
        :tag => "#{n.span?} pg",
        :badge => n.total?
      }
    }
  }
}

node(:last_pg) { @last_pg }

