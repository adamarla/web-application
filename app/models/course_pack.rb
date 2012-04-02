# == Schema Information
#
# Table name: course_packs
#
#  id           :integer         not null, primary key
#  student_id   :integer
#  testpaper_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  marks        :float
#  graded       :boolean         default(FALSE)
#

class CoursePack < ActiveRecord::Base
  belongs_to :student
  belongs_to :testpaper 

  def complete?
    # Complete if scans are available for every graded response
    quiz_id = Testpaper.where(:id => self.testpaper_id).first.quiz.id
    missing = GradedResponse.of_student(student_id).in_quiz(quiz_id).without_scan.count
    return (missing > 0 ? false : true)
  end

  def graded? 
    return true if self.graded

    quiz_id = self.testpaper.quiz.id
    fully_graded = GradedResponse.ungraded.in_quiz(quiz_id).of_student(self.student_id).count > 0 ? false : true
    self.update_attribute(:graded, fully_graded) if fully_graded 
    return fully_graded
  end 

  def marks?
    return self.marks unless self.marks.nil?

    quiz_id = self.testpaper.quiz.id
    marks = GradedResponse.graded.in_quiz(quiz_id).of_student(self.student_id).map(&:marks).inject(:+)
    self.update_attribute(:marks, marks) if self.graded?
    return marks.nil? ? 0 : marks
  end

  def graded_thus_far?
    # Returns the total (of quiz) graded till now. This number will change as more 
    # and more of the student's testpaper is graded 
    return self.testpaper.quiz.total? if self.graded?

    quiz_id = self.testpaper.quiz.id
    graded = GradedResponse.in_quiz(quiz_id).of_student(self.student_id).graded
    thus_far = graded.map(&:q_selection).map(&:question).map(&:marks).inject(:+)
    return thus_far.nil? ? 0 : thus_far # will always be an integer!
  end

end
