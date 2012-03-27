# == Schema Information
#
# Table name: course_packs
#
#  id           :integer         not null, primary key
#  student_id   :integer
#  testpaper_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  marks        :integer
#  graded       :boolean         default(FALSE)
#

class CoursePack < ActiveRecord::Base
  belongs_to :student
  belongs_to :testpaper 

  def graded? 
    return true if self.graded
    quiz_id = self.testpaper.quiz.id
    graded = GradedResponse.in_quiz(quiz_id).of_student(student_id).map{ |x| !x.grade_id.nil? }.inject(:&)
    self.update_attribute(:graded, graded) if graded
    return graded
  end 

  def marks? 
    return nil unless self.graded?
    return self.marks unless self.marks.nil? 

    # Ok, total the marks because they haven't been till now 
    quiz_id = self.testpaper.quiz.id
    marks = GradedResponse.in_quiz(quiz_id).of_student(self.student_id).map(&:marks).inject(:+)
    self.update_attribute :marks, marks
    return marks
  end

end
