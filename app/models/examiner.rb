# == Schema Information
#
# Table name: examiners
#
#  id            :integer         not null, primary key
#  num_contested :integer         default(0)
#  created_at    :datetime
#  updated_at    :datetime
#  secret_key    :string(255)
#  is_admin      :boolean         default(FALSE)
#  first_name    :string(255)
#  last_name     :string(255)
#

class Examiner < ActiveRecord::Base
  has_one :account, :as => :loggable
  has_many :graded_responses

  # [:all] ~> [:admin]
  # [:secret_key] ~> [:examiner] 
  # [:num_contested] ~> [:student]
  #attr_accessible :num_contested
  before_create :set_secret_key

  def name 
    return "#{self.first_name} #{self.last_name} (#{self.account.username})"
  end 

  def self.pending_quizzes
    pending = GradedResponse.ungraded.map(&:q_selection_id).uniq
    quiz_ids = QSelection.where(:id => pending).map(&:quiz_id).uniq
    @quizzes = Quiz.where :id => quiz_ids
  end

  def self.pages( quiz = nil, type = :pending ) # other option is :graded
    # Find all the pages from passed quiz assigned to this particular examiner
    return [] if quiz.nil?

    responses = GradedResponse.in_quiz(quiz.id)
    responses = (type == :pending) ? responses.ungraded : responses.where('grade_id IS NOT NULL')

    @pages = QSelection.where(:id => responses.map(&:q_selection_id).uniq).map(&:page).uniq
  end

  def block_db_slots
    slots = []
    SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['create_question']}" 

    [*1...5].each do |index|
      response = SavonClient.request :wsdl, :create_question do
        soap.body = "#{self.id}"
      end
      manifest = response[:create_question_response][:manifest]
      unless manifest.nil?
        root = manifest[:root] 
        uid = root.split('/').last
        slots << uid
      end
    end # of looping

    # Now, make the DB entries for the slots that were created 
    slots.each do |s|
      q = Question.new :uid => s, :examiner_id => self.id 
      slots.delete s unless q.save
    end
    return slots
  end

  private 
    def set_secret_key 
      x = rand(36**16).to_s(36).rjust(16,"0")
      y = rand(36**16).to_s(36).rjust(16,"0")
      self.secret_key = x + y
    end 

end
