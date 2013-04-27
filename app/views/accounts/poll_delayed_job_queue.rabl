
object false
  node(:quizzes) { @quizzes.map{ |m| { :id => m.id, :name => m.name } } }
  node(:worksheets) { @ws.map{ |m| { :id => m.id, :name => m.name } } }
  node(:enable) { @quizzes.map(&:id) }
