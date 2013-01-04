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

  def self.of_student(id)
    where(:student_id => id)
  end

  def self.for_testpaper(id)
    where(:testpaper_id => id)
  end

  def complete?
    # Complete if scans are available for every graded response of this student
    responses = GradedResponse.in_testpaper(self.testpaper_id).of_student(self.student_id)
    return (responses.without_scan.count > 0 ? false : true)
  end

  def graded? 
    return true if self.graded

    if self.testpaper.publishable
      self.update_attribute :graded, true
      ret = true 
      # Note: there still might not be scans for all responses. But this 
      # method only checks for whether all that have scans have been graded
    else
      ret = GradedResponse.in_testpaper(self.testpaper_id).of_student(self.student_id).ungraded.count > 0
      self.update_attribute(:graded, true) if ret
    end
    return ret
  end 

  def marks?
    return self.marks unless self.marks.nil?

    responses = GradedResponse.in_testpaper(self.testpaper_id).of_student(self.student_id)
    marks = responses.graded.map(&:marks?).select{ |m| !m.nil? }.inject(:+)
    self.update_attributes(:marks => marks, :graded => true) if responses.ungraded.count == 0
    return marks.nil? ? 0 : marks.round(2)
  end

  def graded_thus_far?
    # Returns the total (of quiz) graded till now. This number will change as more 
    # and more of the student's testpaper is graded 
    return self.testpaper.quiz.total? if self.graded?

    responses = GradedResponse.in_testpaper(self.testpaper_id).of_student(self.student_id)
    thus_far = responses.graded.map(&:subpart).map(&:marks).select{ |m| !m.nil? }.inject(:+)
    return thus_far.nil? ? 0 : thus_far # will always be an integer!
  end

  def graded_thus_far_as_str
    # Returns a string of the form "marks / graded_thus_far" - where marks are whats been earned till now
    absent = GradedResponse.of_student(self.student_id).in_testpaper(self.testpaper_id).with_scan.count == 0
    marks = absent ? -1 : self.marks?
    return (absent ? "no scans" : "#{marks} / #{self.graded_thus_far?}")
  end

end
