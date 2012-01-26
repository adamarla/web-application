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
#  klass         :integer
#  subject_id    :integer
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

  validates :teacher_id, :presence => true, :numericality => true
  validates :name, :presence => true

  before_save :set_name, :if => :new_record?
  after_create :lay_it_out

  def assign_to (students) 
    # students : an array of selected students from the DB
    status = :ok
    students.each do |s|
      # Don't issue the same quiz to the same students
      next if s.quiz_ids.include? self.id

      self.questions.each do |q|
        in_quiz = QSelection.where(:quiz_id => self.id, :question_id => q.id).first.id
        response = GradedResponse.new :q_selection_id => in_quiz, :student_id => s.id
        status = (response.save) ? :ok : :bad_request
        break if status == :bad_request
      end # question loop
      break if status == :bad_request
    end # student loop 
    return status
  end 

  def teacher 
    Teacher.find self.teacher_id
  end 

  def set_name
    subject = Subject.where(:id => self.subject_id).select(:name).first.name
    self.name = "#{self.klass}-#{subject} [Week #{Date.today.cweek}, #{Date.today.year}]" # Example : Week #14
  end 

  def lay_it_out
    questions = Question.where(:id => self.question_ids).order(:full_page).order(:half_page)
    page = 1
    score = 0
    index = 1

    questions.each do |q|
      score += (q.mcq ? 0.25 : (q.half_page ? 0.5 : 1))
      if score > 1
        page += 1
        score = 0
      end
      in_quiz = QSelection.where(:question_id => q.id, :quiz_id => self.id).first
      in_quiz.update_attributes :page => page, :index => index
      index += 1
    end
  end # lay_it_out

  def layout?
    # Sample layout --> [{ :number => 1, :question => [{:id => 1}, {:id => 2}] }]
    #
    # The form of the layout returned from here is determined by the WSDL. We 
    # really don't have much choice 

    j = self.q_selections.order(:page).select('question_id, page')
    last = j.last.page 
    layout = [] 

    [*1..last].each do |page|
      q_on_page = j.where(:page => page).map(&:question_id)
      q_on_page.each_with_index do |qid, index|
        q_on_page[index] = { :id => qid }
      end
      layout.push( { :number => page, :question => q_on_page })
    end
    return layout
  end

end
