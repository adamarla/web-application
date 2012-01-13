# == Schema Information
#
# Table name: quizzes
#
#  id            :integer         not null, primary key
#  teacher_id    :integer
#  created_at    :datetime
#  updated_at    :datetime
#  num_questions :integer
#  name          :string(255)
#

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

class Quiz < ActiveRecord::Base
  belongs_to :teacher 

  has_many :q_selections
  has_many :questions, :through => :q_selections

  has_many :graded_responses
  has_many :students, :through => :graded_responses

  validates :teacher_id, :presence => true, :numericality => true
  validates :name, :presence => true

  after_create :lay_it_out

  def assign_to (students) 
    # students : an array of selected students from the DB
    status = :ok
    self.questions.each do |q|
      selection = QSelection.where(:quiz_id => self.id, :question_id => q.id).first.id
      students.each do |s|
        response = GradedResponse.new :q_selection_id => selection, :student_id => s.id
        status = (response.save) ? :ok : :bad_request
        break if status == :bad_request
      end
    end
    return status
  end 

  def teacher 
    Teacher.find self.teacher_id
  end 

  def set_name( klass, subject )
    return false if (klass.blank? || subject.blank?)
    timestamp = "(#{Date.today.strftime '%b %d, %Y'})"
    self.name = "#{subject[0]}#{klass} #{timestamp}"
  end 

  def lay_it_out
    questions = Question.where(:id => self.question_ids).order(:mcq).order(:half_page).order(:full_page)
    page = 1
    score = 0

    questions.each do |q|
      score += (q.mcq ? 0.25 : (q.half_page ? 0.5 : 1))
      if score > 1
        page += 1
        score = 0
      end
      selection = QSelection.where(:question_id => q.id, :quiz_id => self.id).first
      selection.update_attribute :page, page
    end


  end

end
