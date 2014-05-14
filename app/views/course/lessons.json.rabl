
object false
  node(:type) { :lessons }
  node(:id, unless: @c.nil?) { @c.id }
  node(:used, unless: @c.nil?){
    @c.lessons.map{ |l| { id: l.id, name: l.title } }
  }

  node(:available, unless: @c.nil?){
    @c.includeable_lessons?.order(:title).map{ |l| { id: l.id, name: l.title } }
  }
