
object false
  node(:quizzes) { @quizzes.map{ |m| { :id => m.id, :name => m.name } } }
  node(:worksheets) { @ws.map{ |m| { :id => m.id, :name => m.name } } }
  node(:enable) { @quizzes.map(&:id) }

  node(:demo) { 
    @demo.map { |m| { :id => m.quiz.parent_id, :a => encrypt(m.id, 7), :b => m.quiz_id, :c => m.id } }
  } 
