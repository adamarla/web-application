
collection @students => :students 
  attributes :name, :id

  node do |s|
    c = CoursePack.where(:student_id => s.id, :testpaper_id => @testpaper.id).first
    marks = c.marks?
    thus_far = c.graded_thus_far? 
    p = (thus_far > 0) ? ((marks/thus_far)*100).round(2) : 0

    { :graded => c.graded?, :marks => marks, :graded_thus_far => thus_far, :percentage => p } 
  end

