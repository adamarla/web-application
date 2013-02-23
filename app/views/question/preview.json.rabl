
# Returned json : { :preview => { :id => '1-4hy-9020j', :scans => [0,1,2,3] } }
# This form is in keeping with what is used in quizzes/preview & 
# quizzes/get_candidates

object false
  node(:preview) {
    { :id => @question.simple_uid, :scans => [*1..@question.answer_key_span?] } 
  } 
  node(:caption) { @question.uid }
