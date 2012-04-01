
collection @testpapers => :testpapers 
  attributes :name, :id
  code :atm do |t|
    t.quiz.atm_key
  end
