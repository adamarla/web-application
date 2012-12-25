
collection @publishable => :wrks
  attribute :id
  node(:name) { |m| m.quiz.name }
  node(:tag) { |m| m.closed_on?.strftime('%b %d, %Y') }
