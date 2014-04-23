
object false
  node(:type) { :quizzes }
  node(:used, unless: @c.nil?){
    @c.quizzes.map{ |q| { id: q.id, name: q.name } }
  }

  node(:available, unless: @c.nil?){
    @c.includeable_quizzes?.order(:name).map{ |q| { id: q.id, name: q.name } }
  }

