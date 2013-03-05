
collection @sektions => :sektions 
  attribute :id
  attribute :label => :name
  node(:tag) { |m| "#{m.students.count} student(s)" }
