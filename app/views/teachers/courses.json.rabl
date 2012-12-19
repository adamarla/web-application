
collection @courses => :courses
  attributes :name, :id
  node(:tag) { |m| "#{m.board.name}" }
