
collection @teachers => :teachers 
  attributes :id, :name
  node(:ticker) { |m| m.account.username unless m.account.nil? }
