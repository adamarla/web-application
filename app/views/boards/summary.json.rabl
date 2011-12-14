
collection @boards => :boards 

attribute :name 
code :course_count do |m| 
  m.courses.count
end 
