
object false 
  node(:course, unless: @c.nil?){
    { name: @c.title, 
      author: @c.teacher.name,
      id: @c.id, 
      description: @c.description }
  }
