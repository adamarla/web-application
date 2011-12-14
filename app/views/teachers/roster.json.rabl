
collection @study_groups => :sections 
  attributes :id
  code :name do |m| 
    m.name 
  end 

  code :checked do |m| 
    m.taught_by? @teacher
  end 
