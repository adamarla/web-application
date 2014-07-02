
object false 

node(:quizzes) { 
  @quizzes.map{ |n|
    {
      name: n.name,
      id: n.id,
      tag: (n.compiling? ? "#{minutes_to_completion(n.job_id)} min" : "#{n.span?} pg"),
      badge: n.total?
    }
  }
}

node(:last_pg) { @last_pg }
node(:disabled) { @disabled }
node(:indie, unless: @t.nil?) { @indie } 
node(:ping) { @ping }

