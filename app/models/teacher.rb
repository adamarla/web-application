# == Schema Information
#
# Table name: teachers
#
#  id         :integer         not null, primary key
#  first_name :string(30)
#  last_name  :string(30)
#  created_at :datetime
#  updated_at :datetime
#  school_id  :integer
#  country_id :integer
#  zip_code   :string(10)
#

#     __:has_many_____     ___:has_many___  
#    |                |   |               | 
#  Teacher --------> Quizzes ---------> Questions 
#    |                |   |               | 
#    |__:belongs_to___|   |___:has_many___| 
#    

require 'rexml/document'
include REXML
include ApplicationUtil

class Teacher < ActiveRecord::Base
  belongs_to :country
  has_one :account, :as => :loggable, :dependent => :destroy
  has_one :trial_account, :dependent => :destroy

  has_many :quizzes, :dependent => :destroy 
  has_many :sektions, :dependent => :destroy

  has_many :favourites, :dependent => :destroy
  has_many :suggestions

  validates :first_name, :presence => true  
  validates_associated :account

#  after_create :generate_suggestion_form
  after_save   :reset_login_info

=begin
  Destroying a teacher should be a very rare event. It probably 
  shouldn't be done even if the teachers leaves the school. But then
  again, there might be situations - like when rationalizing DB records - 
  when one might have to destroy some teacher records 

  The point is - cross the bridge when it comes 
=end

  #after_validation :setup_account, :if => :first_time_save?
  #before_destroy :destroyable? 

  def students 
    sk = Sektion.where(:teacher_id => self.id).map(&:id)
    sids = StudentRoster.where(:sektion_id => sk).map(&:student_id).uniq
    return Student.where(:id => sids)
  end 

  def benchmark(topic, level = :senior)
    target_difficulty = level == :senior ? 3 : (level == :junior ? 1 : 2)

    qids = QSelection.where(:quiz_id => self.quiz_ids).map(&:question_id) 
    questions = Question.where(:id => qids).on_topic(topic).difficulty(target_difficulty)
    return 0 if questions.count == 0 

    subparts = Subpart.where(:question_id => questions.map(&:id))
    score = 0 
    [*1..6].each do |marks|
      score += (marks * subparts.where(:marks => marks).count)
    end
    weighted = (score / subparts.count.to_f).round(2)
    return weighted
  end

  def suggested_questions( type = :completed ) # other possible values: :all, :wip, :just_in
    s_objs = Suggestion.where(:teacher_id => self.id)
    case type
      when :completed
        s_objs = s_objs.completed
      when :wip then 
        s_objs = s_objs.wip
      when :just_in then 
        s_objs = s_objs.just_in
    end # of case 

    q_ids = s_objs.map(&:question_ids).flatten.uniq
    return Question.where(:id => q_ids)
  end

=begin
  def build_quiz_with (name, question_ids, parent_id = nil)
    @quiz = Quiz.new :teacher_id => self.id, :question_ids => question_ids, 
                     :num_questions => question_ids.count, 
                     :name => name, :parent_id => parent_id

    # Ideally, one should ask for the TeX to be compiled before saving
    # @quiz into the database. But in this case, we need a quiz-ID and its layout 
    # before we can go in for TeX compilation. So, we save first and delete if TeX 
    # compilation fails

    status = @quiz.save ? :ok : :bad_request
    response = {}

    unless status == :bad_request
      response = @quiz.compile_tex
      manifest = response[:manifest]
      status = manifest.blank? ? :bad_request : :ok

      if status == :bad_request 
        @quiz.destroy
      else
        # The atm-key is the randomized access point to this quiz in mint/
        uid = Quiz.extract_uid manifest[:root] 
        span = manifest[:image].class == Array ? manifest[:image].count : 1
        @quiz.update_attributes :uid => uid, :span => span
        response = {:atm_key => uid, :name => @quiz.name }

        # Increment n_picked for each of the questions picked for this quiz
        Question.where(:id => question_ids).each do |m|
          m.increment_picked_count
        end 
      end
    end
    return response, status
  end
=end

  def username?
    self.account.username
  end 

  def name
    return self.last_name.nil? ? self.first_name : "#{self.first_name} #{self.last_name}"
  end 

  def name=(name)
    split = name.split
    last = split.count - 1
    self.first_name = split.first.humanize

    if last > 0
      middle = split[1...last].map{ |m| m.humanize[0] }.join('.')
      self.last_name = middle.empty? ? "#{split.last.humanize}" : "#{middle} #{split.last.humanize}"
    end
  end

  def roster 
    # Yes, yes.. We could have gotten the same thing by simply calling self.sektions
    # But if we return an ActiveRelation, then we get the benefit of lazy loading
    Sektion.joins(:faculty_rosters).where('faculty_rosters.teacher_id = ?', self.id)
  end 

  def set_subjects(list_of_ids = [])
    list_of_ids.each_with_index { |a, index| list_of_ids[index] = a.to_i } 
    self.subjects = Subject.where :id => list_of_ids
  end

  def worksheets
=begin
    A teacher can access:
      1. any worksheets for her quizzes (obviously)
      2. any public/non-exclusive worksheets from her colleagues
          a. these worksheets would have been made public by the colleague herself.
             And so, its ok to show them
=end
    of_colleagues = Quiz.where(:teacher_id => self.colleagues.map(&:id))
    others = Testpaper.where(:exclusive => false, :quiz_id => of_colleagues.map(&:id)).map(&:id)

    my_own = Testpaper.where(:quiz_id => Quiz.where(:teacher_id => self.id)).map(&:id)
    total = (others + my_own).uniq

    @worksheets = Testpaper.where(:id => total).order('created_at DESC')
  end

  def like_question(question_id)
    m = Favourite.where(:teacher_id => self.id, :question_id => question_id)
    return unless m.empty? # no double-addition
    self.favourites.create :question_id => question_id # will also save to the DB
  end

  def unlike_question(question_id)
    m = Favourite.where(:teacher_id => self.id, :question_id => question_id)
    return if m.empty?
    m = m.first
    self.favourites.delete m # will also destroy because of the :dependent => :destroy
  end

  def display_sektions_list
    return self.sektions << Sektion.find_by_id(GRADIANS_ID)
  end

  GRADIANS_ID = 58

#####  PRIVATE ######################

  private 
    
    def reset_login_info
      new_prefix = username_prefix_for self, :teacher
      u = self.account.username.sub(/^\w+\./, "#{new_prefix}.")
      self.account.update_attributes :username => u
    end

    def setup_account 
      self.build_account
    end 

    def destroyable? 
      return false 
    end 

    def first_time_save? 
      self.new_record? || !self.account
    end 

    def generate_suggestion_form
      # At any given time, there is at most one copy of suggestion.tex in front-desk/.
      # Hence, if > 1 requests for generating suggestion form are sent (after_create), then 
      # each subsequent request will overwrite the suggestion.tex from the previous request.
      # And therefore, to keep things clean, we have to process each request individually
      # by placing it in the queue
      Delayed::Job.enqueue BuildSuggestionForm.new(self), :priority => 5, :run_at => Time.zone.now 
    end

end # of class 
