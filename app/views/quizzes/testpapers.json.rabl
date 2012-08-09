
collection @testpapers => :testpapers
  attributes :name, :id
  node (:parent) { |m| @quiz.atm_key }
  node (:parent_id) { |m| @quiz.id }
  node(:ticker) { |m| m.created_at.to_date.strftime("%b %d, %Y") }
