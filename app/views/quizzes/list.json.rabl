
collection @quizzes => :quizzes
  attribute :atm_key => :id 
  attribute :name

  child :testpapers => :testpapers do 
    attributes :id, :name
  end 
