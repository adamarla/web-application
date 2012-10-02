
collection @publishable => :testpapers 
  attribute :id
  node(:name) { |m| m.quiz.name }
  node(:atm) { |m| m.quiz.atm_key }
