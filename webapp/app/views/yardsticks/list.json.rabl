
collection @yardsticks => :yardsticks 
  attributes :id, :mcq, :subpart

  code :name do |y| 
    y.name
  end 
