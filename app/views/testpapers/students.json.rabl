
collection @students => :students 
  attributes :name, :id

  code :graded do |s|
    c = CoursePack.where(:student_id => s.id, :testpaper_id => @testpaper.id).first
    c.graded?
  end
