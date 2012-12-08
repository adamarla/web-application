
object false 

node(:quizzes) { 
  @quizzes.map{ |n|
    {
      :quiz => {
        :name => n.name
      }
    }
  }
}

node(:last_pg) { @last_pg }

