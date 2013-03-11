# == Schema Information
#
# Table name: students
#
#  id          :integer         not null, primary key
#  guardian_id :integer
#  first_name  :string(30)
#  last_name   :string(30)
#  created_at  :datetime
#  updated_at  :datetime
#  uid         :string(20)
#

include ApplicationUtil

class Student < ActiveRecord::Base
  belongs_to :guardian

  has_many :student_rosters, :dependent => :destroy 
  has_many :sektions, :through => :student_rosters

  # belongs_to :sektion
  has_one :account, :as => :loggable, :dependent => :destroy

  has_many :graded_responses
  has_many :quizzes, :through => :graded_responses

  has_many :answer_sheets
  has_many :testpapers, :through => :answer_sheets

  validates :first_name, :presence => true

  after_save  :reset_login_info
  after_create  :generate_uid

  # When should a student be destroyed? My guess, some fixed time after 
  # he/she graduates. But as I haven't quite decided what that time should
  # be, I am temporarily disabling all destruction

  before_destroy :destroyable? 

  def self.name_begins_with( allowed = [] )
    return if allowed.empty? 
    select{ |m| allowed.include? m.first_name[0] }
  end

  def username?
    self.account.username
  end 
  
  def abbreviated_name
    return self.last_name.nil? ? self.first_name : "#{self.first_name}-#{self.last_name[0]}"
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

  def inbox
    # Returns the worksheets that should be shown in a student's inbox
    assigned = AnswerSheet.where(:student_id => self.id)
    received = assigned.where(:received => true)
    due = assigned.map(&:testpaper_id) - received.map(&:testpaper_id)
    Testpaper.where(:id => due, :inboxed => true) 
  end

  def outbox
    # Returns the worksheets that should be shown in a student's outbox
    # Any student worksheet - with scans - but not yet graded ( at all ) 
    # should be in the outbox
    assigned = self.testpapers.map(&:id) 
    g = GradedResponse.in_testpaper(assigned).of_student(self.id)

  end

  def teachers
    Teacher.joins(:sektions).where('sektions.id = ?', self.sektion_id)
  end 

  def quiz_ids
    t_ids = AnswerSheet.where(:student_id => self.id).map(&:testpaper_id)
    quiz_ids = Testpaper.where(:id => t_ids).map(&:quiz_id).uniq
    return quiz_ids
  end

  def marks_scored_in(testpaper_id)
    a = AnswerSheet.where(:student_id => self.id, :testpaper_id => testpaper_id).first 
    marks = a.nil? ? 0 : a.marks?
    return marks unless marks == 0
    return (self.absent_for_test?(testpaper_id) ? -1 : marks) 
  end

  def honestly_attempted? (ws_id)
    a = AnswerSheet.where(:student_id => self.id, :testpaper_id => ws_id).first
    return a.nil? ? :disabled : a.honest?
  end

  def responses(testpaper_id)
    a = GradedResponse.of_student(self.id).in_testpaper(testpaper_id).with_scan
    return a.sort{ |m,n| m.q_selection.index <=> n.q_selection.index }
  end

  def expectations_met_in(topic_id)
    # Returns the weighted average percentage earned by a student on
    # a given topic on the questions his/her teacher set
    # Returns: a number in [0,1]
    g = GradedResponse.of_student(self.id).graded.on_topic(topic_id)
    sids = g.map(&:subpart_id).uniq

    earned = 0 
    [*1..6].each do |marks|
      having = g.select{ |m| m.subpart.marks == marks }
      next if having.count == 0
      avg = (having.map(&:system_marks).inject(:+) / having.count.to_f).round(2) # avg score on 'k' mark questions
      earned += avg
    end 
    max = Subpart.where(:id => sids).map(&:marks).uniq.inject(:+)
    weighted = max.nil? ? 0 : (earned/max).round(2)
  end 

  def absent_for_quiz?(quiz_id)
    tids = AnswerSheet.where(:student_id => self.id).map(&:testpaper_id)
    qids = Testpaper.where(:id => tids).map(&:quiz_id)
    took_test = qids.include? quiz_id 
    return true if !took_test

    g = GradedResponse.of_student(self.id).in_quiz(quiz_id).with_scan
    return g.count == 0
  end

  def absent_for_test?(testpaper_id)
    g = GradedResponse.of_student(self.id).in_testpaper(testpaper_id).with_scan
    return g.count == 0
  end

  def proficiency(teacher_id)
    all = GradedResponse.in_quiz(Quiz.where(:teacher_id => teacher_id).map(&:id)).graded

    of_student = all.of_student self.id

    topics = of_student.map(&:q_selection).map(&:question).map(&:topic).map(&:id).uniq
    topics = Topic.where(:id => topics).sort{ |m,n| m.name <=> n.name }
    ret = { :proficiency => [ {:name => "Example", :score => 0.43, :benchmark => 3.5, :historical_avg => 2.5 } ] }

    topics.each do |t|
      # student-specific
      on_topic = of_student.on_topic t.id
      marks = on_topic.map(&:subpart).map(&:marks)
      n_attempted = marks.count
      total = marks.inject(:+)
      scored = on_topic.map(&:system_marks).inject(:+)

      # historical average on topic
      all_on_topic = all.on_topic t.id 
      historical_avg = (all_on_topic.map(&:system_marks).inject(:+) / all_on_topic.count.to_f).round(2)

      ret[:proficiency].push({ :id => t.id, :name => t.name, 
                               :score => (scored/total.to_f).round(2),
                               :benchmark => (total/n_attempted.to_f).round(2),
                               :historical_avg => historical_avg })
    end
    return ret
  end

  def generate_uid
    if self.uid.nil?
      SavonClient.http.headers["SOAPAction"] = "#{Gutenberg['action']['generateStudentCode']}"
      response = SavonClient.request :wsdl, :generateStudentCode do
        soap.body = { :id => self.id }
      end
      manifest = response[:generate_student_code_response][:manifest]
      unless manifest.nil?
        root = manifest[:root]
        self.uid = root.split('/').last 
        self.save
      end
    end
  end

  private 
    def destroyable? 
      return false 
    end 

    def reset_login_info
      new_prefix = username_prefix_for(self, :student)
      u = self.account.username.sub(/^\w+\./, "#{new_prefix}.")
      self.account.update_attributes :username => u
    end

end # of class 
