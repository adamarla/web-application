
collection @students => :students
  attributes :name, :id 
  node(:login) { |m| m.username? } 
  node(:parent) { |m| m.klass }
