
collection @topics => :topics
  attributes :name, :id

  # The JSON generated here is loaded onto an HTML element that includes - 
  # amongst other things - a <select> menu. As the element is intended to 
  # be generic and re-usable, we cannot build the JSON using any context 
  # specific keys. If we did, then we wouldn't be able to keep the JS code
  # that loads the JSON onto the HTML DRY as new versions would have to be 
  # written for each new context. Hence, rather than define a key called 
  # difficulty below, we use the more generic term :select

  code :select do |m|
    x = Syllabus.where(:course_id => @course.id, :topic_id => m.id).first
    x.nil? ? nil : x.difficulty
  end 
