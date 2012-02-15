
  node :preview do 
    { :id => @course.id, :indices => @questions.map(&:uid) }
  end

  node :questions do
    @questions.map{ |q| { :question => { :id => q.id, :name => q.uid } } }
  end


