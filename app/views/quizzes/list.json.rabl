
collection @quizzes => :quizzes
  attributes :id, :name 
  attribute :atm_key => :randomized_id 

  child :testpapers => :testpapers do 
    attributes :id, :name
  end 
