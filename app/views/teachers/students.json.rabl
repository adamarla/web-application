
collection @students => :students
  attributes :name, :id 
  node(:ticker) { |m| m.username? } 
  node(:parent) { |m| m.klass }
