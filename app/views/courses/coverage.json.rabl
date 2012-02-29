
collection @verticals => :verticals
  attributes :id
  code :in do |m|
    @course.covers_vertical? m.id
  end 

  child :topics => :micros do 
    attributes :id

    # The JSON generated here is loaded onto an HTML element that includes - 
    # amongst other things - a <select> menu. As the element is intended to 
    # be generic and re-usable, we cannot build the JSON using any context 
    # specific keys. If we did, then we wouldn't be able to keep the JS code
    # that loads the JSON onto the HTML DRY as new versions would have to be 
    # written for each new context. Hence, rather than define a key called 
    # difficulty below, we use the more generic term :select

    code :select do |k|
      k.difficulty_in @course.id
    end 
  end 
