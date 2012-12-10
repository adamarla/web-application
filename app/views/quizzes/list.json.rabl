
object false 

node(:quizzes) { 
  @quizzes.map{ |n|
    {
      :quiz => {
        :name => n.name,
        :id => n.id
      }
    }
  }
}

node(:last_pg) { @last_pg }

