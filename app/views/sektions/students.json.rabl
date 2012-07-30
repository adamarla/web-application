
collection @students => :students
  attributes :id, :name
  node(:login) { |m| m.account.username }
