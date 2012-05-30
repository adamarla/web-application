
collection @testpapers => :testpapers
  attributes :name, :id
  node (:parent) { |m| @quiz.atm_key }
