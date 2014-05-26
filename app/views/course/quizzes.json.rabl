
object false
  node(:id) { @c.id }
  if @is_student 
    node(:disabled) { @disabled }
    node(:quizzes) { @c.quizzes.map{ |q| { 
      id: q.id, 
      name: q.name, 
      tag: @disabled.include?(q.id) ? "compiling" : "" } } }
    node(:download, unless: @ready.blank?) { @ready.map{ |w| { id: w.exam.quiz_id, path: w.download_pdf? } } }
    node(:monitor, unless: @queued.blank?) { { worksheets: @queued } }
  else
    node(:type) { :quizzes }
    node(:used){ @c.quizzes.map{ |q| { id: q.id, name: q.name } } }
    node(:available){ @c.includeable_quizzes?.order(:name).map{ |q| { id: q.id, name: q.name } } }
  end



