
object @testpaper => false 
  node(:mean) { |testpaper| testpaper.mean? }

  child :students do |s|
    attributes :name, :id
    code do |m|
      a = AnswerSheet.where(:student_id => m.id, :testpaper_id => @testpaper.id).first
      marks = a.marks? 
      thus_far = a.graded_thus_far?
      p = (thus_far > 0) ? ((marks/thus_far)*100).round(2) : 0
      { :marks => marks, :graded => a.graded?, :graded_thus_far => thus_far, :percentage => p }
    end
  end
