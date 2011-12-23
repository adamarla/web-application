
collection @micros => :micros
  attributes :name, :id

  code :difficulty do |m|
    x = Syllabus.where(:course_id => @course.id, :micro_topic_id => m.id).first
    x.nil? ? nil : x.difficulty
  end 
