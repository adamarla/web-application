
# Returned json : { :preview => { :id => '1-4hy-9020j', :scans => [0,1,2,3] } }
# This form is in keeping with what is used in quizzes/preview & 
# quizzes/get_candidates

object @question => :preview
  attribute :difficulty
  node(:restricted) { |m| m.restricted ? "true" : "false" }
  node(:scans) { |m| [*1..m.answer_key_span?] }
  node(:id) { |m| m.uid }

#  code :preview do |q| 
#    { :id => q.uid, :scans => [*1..q.answer_key_span?], :restricted => (q.restricted ? "true" : "false"), 
#      :difficulty => q.difficulty}
#  end 
