
collection @sektions => :sektions 
  attributes :id
  code :name do |m| 
    m.name 
  end 

  code :checked do |m| 
    m.taught_by? @teacher
  end 
