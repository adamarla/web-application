
collection @publishable => :wrks
  attribute :id
  node(:name) { |m| m.quiz.name }
