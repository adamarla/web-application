
collection @wks => :wks
  attributes :id, :name 
  node(:tag) { |m| m.quiz.name }
