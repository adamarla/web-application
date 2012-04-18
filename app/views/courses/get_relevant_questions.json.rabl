
# { :preview => { :id => ['1-hxy-783', '1-78z-783jn'], :scans => [[1,2],[1,2,3,4]] } }

  node :preview do 
    { :id => @questions.map(&:uid), :scans => @questions.map{ |m| [*1..m.answer_key_span?] } }
  end

  node :questions do
    @questions.map{ |q| { :question => { :id => q.id, :name => q.uid } } }
  end


