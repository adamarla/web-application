
collection @students => :students
  attributes :id, :name
  node(:login) { |m| m.username? }
  node(:parent) { |m| m.klass }
