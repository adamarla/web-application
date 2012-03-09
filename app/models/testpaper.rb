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
  has_many :course_packs, :dependent => :destroy
  has_many :students, :through => :course_packs

  def compile_tex
    student_ids = CoursePack.where(:testpaper_id => self.id).select(:student_id).map(&:student_id)
    students = Student.where(:id => student_ids)

    names = []
    students.each do |s|
      names.push({ :id => s.id, :name => s.name })
    end

    puts " +++++ "
    puts " #{names}" 
    puts " +++++ "

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

  def assignees
    @students = self.students
  end

end # of class
