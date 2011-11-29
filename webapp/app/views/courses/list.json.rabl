
collection @courses => :courses

code :name do |m| 
  # example : O-Level (Physics) 
  m.name + " (" + m.subject.name + ")"
end 

code :board do |m| 
  m.board.name
end 

attributes :grade => :klass
attribute :id
