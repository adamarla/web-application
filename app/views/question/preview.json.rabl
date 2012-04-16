
# Returned json : { :preview => { :id => '1-4hy-9020j', :indices => [0,1,2,3] } }
# This form is in keeping with what is used in quizzes/preview & 
# quizzes/get_candidates

object @question => false
  code :preview do |q| 
    { :id => q.uid, :indices => [*1..q.answer_key_span?] }
  end 
