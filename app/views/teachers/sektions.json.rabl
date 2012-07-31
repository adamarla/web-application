
collection @sektions => :sektions 
  attribute :id
  attribute :label => :name
  node(:ticker) { |m| "#{m.students.count} student(s)" }
