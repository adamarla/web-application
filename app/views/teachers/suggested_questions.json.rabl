
collection @questions => :typesets
  attribute :id
  attribute :uid => :name 
  node(:ticker) { |m| m.topic.name }
