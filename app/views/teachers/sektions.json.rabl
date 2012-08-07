
collection @sektions => :sektions 
  attribute :id
  attribute :label => :name
  node(:ticker) { |m| "#{m.students.count} student(s)" }
  node(:lookin) { |m| m.school_id }
  node(:lookfor) { |m| m.pdf }
