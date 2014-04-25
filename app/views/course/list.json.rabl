
object false 
  node(:tiles, unless: @courses.blank?){
    @courses.map{ |c| { name: c.title, 
                        id: c.id, 
                        author: c.teacher.name, 
                        num_quizzes: c.quizzes.count, 
                        num_lessons: c.lessons.count } }
  }
