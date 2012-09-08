
collection @students => :students
  attributes :id, :name
  node(:ticker) { |m| m.username? }
  node(:parent) { |m| m.klass }
