
collection @students => :students 
  attributes :name 
  index = 1
  code :x do |m|
    m.mastery_level?(@topic.id)
  end

  code :y do |m|
    index += 1
  end
