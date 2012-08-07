
collection @sektions => :sektions 
  attribute :id
  attribute :label => :name
  node(:ticker) { |m| "#{m.students.count} student(s)" }
  node(:lookin) { |m| "#{@teacher.school_id}-#{@teacher.id}" }
  node(:lookfor) { |m| "#{m.pdf}" }
