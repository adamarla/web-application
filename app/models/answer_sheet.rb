# == Schema Information
#
# Table name: answer_sheets
#
#  id           :integer         not null, primary key
#  student_id   :integer
#  testpaper_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  marks        :float
#  graded       :boolean         default(FALSE)
#

class AnswerSheet < ActiveRecord::Base
  belongs_to :student
  belongs_to :testpaper 

  def complete?
    # Complete if scans are available for every graded response of this student
    responses = GradedResponse.in_testpaper(self.testpaper_id).of_student(self.student_id)
    return (responses.without_scan.count > 0 ? false : true)
    # quiz_id = Testpaper.where(:id => self.testpaper_id).first.quiz_id
    # missing = GradedResponse.of_student(student_id).in_quiz(quiz_id).without_scan.count
    # return (missing > 0 ? false : true)
  end

  def graded? 
    return true if self.graded

    responses = GradedResponse.in_testpaper(self.testpaper_id).of_student(self.student_id)
    fully_graded = responses.ungraded.count > 0 ? false : true
    #quiz_id = self.testpaper.quiz_id
    #fully_graded = GradedResponse.ungraded.in_quiz(quiz_id).of_student(self.student_id).count > 0 ? false : true
    self.update_attribute(:graded, fully_graded) if fully_graded 
    return fully_graded
  end 

  def marks?
    return self.marks unless self.marks.nil?

    responses = GradedResponse.in_testpaper(self.testpaper_id).of_student(self.student_id)
    marks = responses.graded.map(&:marks).select{ |m| !m.nil? }.inject(:+)

    # marks = GradedResponse.graded.in_quiz(quiz_id).of_student(self.student_id).map(&:marks).select{ |m| !m.nil? }.inject(:+)
    self.update_attribute(:marks, marks) if responses.ungraded.count == 0
    return marks.nil? ? 0 : marks.round(2)
  end

  def graded_thus_far?
    # Returns the total (of quiz) graded till now. This number will change as more 
    # and more of the student's testpaper is graded 
    return self.testpaper.quiz.total? if self.graded?

    responses = GradedResponse.in_testpaper(self.testpaper_id).of_student(self.student_id)
    thus_far = responses.graded.map(&:subpart).map(&:marks).select{ |m| !m.nil? }.inject(:+)
    # quiz_id = self.testpaper.quiz_id
    # graded = GradedResponse.in_quiz(quiz_id).of_student(self.student_id).graded
    # thus_far = graded.map(&:q_selection).map(&:question).map(&:marks).select{ |m| !m.nil? }.inject(:+)
    return thus_far.nil? ? 0 : thus_far # will always be an integer!
  end

end
