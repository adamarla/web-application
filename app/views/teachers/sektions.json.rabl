
collection @sektions => :sektions 
  attribute :id
  attribute :label => :name
  node(:ticker) { |m| "#{m.students.count} student(s)" }
  node(:lookin) { |m| "#{m.school_id}/rosters }
  node(:lookfor) { |m| "#{m.id}-#{m.pdf}" }
