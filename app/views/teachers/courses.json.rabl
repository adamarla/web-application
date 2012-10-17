
collection @courses => :courses
  attributes :name, :id
  node(:ticker) { |m| "#{m.board.name}" }
