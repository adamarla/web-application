
collection @quizzes => :quizzes
  attributes :id, :name
  child :testpapers do 
    attributes :id, :name
  end 
