
object false 

node(:quizzes) { 
  @quizzes.map{ |n|
    {
      :quiz => {
        :name => n.name,
        :id => n.id,
        :tag => (n.compiling? ? "#{n.est_minutes_to_compilation?} min" : "#{n.span?} pg"),
        :badge => n.total?
      }
    }
  }
}

node(:last_pg) { @last_pg }
node(:disable) { @disable }

