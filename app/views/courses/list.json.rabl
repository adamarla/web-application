
collection @courses => :courses
  attribute :id
  node(:name) { |m| "#{m.board.name} - #{m.name}" }
