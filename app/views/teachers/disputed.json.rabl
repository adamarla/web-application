
collection @disputed => :disputed
  attribute :id
  node(:name) { |m| m.name? }
  node(:ticker) { |m| m.student.name }
  node(:numeric) { |m| m.marks? }
  node(:superscript) { |m| "/ #{m.subpart.marks}" }
