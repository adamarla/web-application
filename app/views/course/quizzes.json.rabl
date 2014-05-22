
object false
  node(:id) { @c.id }
  if @is_student 
    node(:quizzes) { @c.quizzes.map{ |q| { id: q.id, name: q.name } } }
  else
    node(:type) { :quizzes }
    node(:used){ @c.quizzes.map{ |q| { id: q.id, name: q.name } } }
    node(:available){ @c.includeable_quizzes?.order(:name).map{ |q| { id: q.id, name: q.name } } }
  end



