
collection @questions => :questions
  attribute :id
  attribute :uid => :name
  node(:ticker) { |m| m.ticker? }
