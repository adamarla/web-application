
object false 
  node(:tiles, unless: @courses.blank?){
    @courses.map{ |c| { name: c.title, id: c.id, author: c.teacher.name } }
  }
