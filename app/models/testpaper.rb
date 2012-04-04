# == Schema Information
#
# Table name: testpapers
#
#  id         :integer         not null, primary key
#  quiz_id    :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Testpaper < ActiveRecord::Base
  belongs_to :quiz

  has_many :graded_responses, :dependent => :destroy 
  has_many :answer_sheets, :dependent => :destroy
  has_many :students, :through => :answer_sheets

  def compile_tex
    student_ids = AnswerSheet.where(:testpaper_id => self.id).select(:student_id).map(&:student_id)
    students = Student.where(:id => student_ids)

    names = []
    students.each do |s|
      names.push({ :id => s.id, :name => s.name })
    end

    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['assign_quiz']}"

    response = SavonClient.request :wsdl, :assign_quiz do  
      soap.body = { 
        :quiz => { :id => self.quiz_id, :name => self.quiz.teacher.school.name },
        :instance => { :id => self.id, :name => self.name },
        :students => names 
      }
    end
    return response.to_hash[:assign_quiz_response]
  end #of method

  def mean?
    # Returns the average % for the class/group that took this testpaper
    # Only graded responses and only those students that have
    # some or all of their answer-sheet graded are considered. Hence, know 
    # that this number will change with time before settling to a final value

    individual_scores = []
    AnswerSheet.where(:testpaper_id => self.id).each do |a|
      thus_far = a.graded_thus_far?
      next if thus_far == 0
      marks = a.marks? 
      score = ((marks/thus_far)*100).round(2)
      individual_scores.push score
    end
    total = individual_scores.inject(:+)
    return (total / individual_scores.count).round(2)
  end

  def takers
    self.students.order(:first_name)
  end

end # of class
