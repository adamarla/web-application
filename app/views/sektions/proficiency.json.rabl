
collection @students => :students 
  attributes :name 
  index = 1
  code :x do |m|
    m.proficiency?(@topic.id)
  end

  code :y do |m|
    index += 1
  end
