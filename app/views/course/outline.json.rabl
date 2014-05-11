
object false 
  node(:course, unless: @c.nil?){
    { name: @c.title, 
      author: @c.teacher.name,
      id: @c.id, 
      description: @c.description, 
      quizzes: @c.quizzes.map{ |q| { name: q.name, id: q.id, uid: q.uid } },
      lessons: @c.lessons.map{ |l| { name: l.title, id: l.id } } }
  }
