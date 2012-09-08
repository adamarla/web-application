
# { :preview => { :id => ['1-hxy-783', '1-78z-783jn'], :scans => [[1,2],[1,2,3,4]] } }

node :topics do 
  @topics.map{ |m| { :topic => {:name => m.name, :id => m.id} } }
end

node :questions do 
  @questions.map{ |m| { :question => {:name => m.uid, :id => m.id, 
                        :parent => m.topic_id, 
                        :ticker => "#{m.marks?} pts", 
                        :liked => Favourite.where(:question_id => m.id).count,
                        :span => m.span? } } }
end

node :favourites do 
  @fav 
end

node :preview do
  { :id => @questions.map(&:uid), 
    :scans => @questions.map{ |m| [*1..m.answer_key_span?] } }
end



