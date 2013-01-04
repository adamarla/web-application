
collection @wks => :wks
  attribute :id
  node(:name) { |m| m.quiz.name }
  node(:tag) { |m| m.name }
