
collection @topics => :topics 
  attributes :name, :id
  node(:parent) { |m| m.vertical_id }
