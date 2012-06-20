
collection @topics => :topics 
  attributes :name, :id 
  node(:parent) { |m| m.vertical_id }
  node(:select) { |m| m.difficulty_in @course }
