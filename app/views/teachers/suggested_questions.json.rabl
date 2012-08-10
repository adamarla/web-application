
collection @questions => :typesets

  node :typesets do 
    @questions.map{ |m| { :typset => {:id => m.id, :name => m.uid, :ticker => m.topic.name }  } } 
  end

  node :preview do
    { :id => @questions.map(&:uid), :scans => @questions.map{ |m| [*1..m.answer_key_span?] } }
  end
