
collection @students => :students
  attribute :id
  node(:parent) { |m| m.klass }
