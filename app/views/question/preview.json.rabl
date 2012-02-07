
# Returned json : { :preview => { :id => 5, :indices => [5] } }
# This form is in keeping with what is used in quizzes/preview & 
# quizzes/get_candidates

object @question => false
  code :preview do |q| 
    { :id => q.id, :indices => [q.uid] }
  end 
