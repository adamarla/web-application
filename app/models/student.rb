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

  has_one :account, :as => :loggable, :dependent => :destroy

  has_many :graded_responses, :dependent => :destroy
  has_many :quizzes, :through => :graded_responses

  has_many :answer_sheets, :dependent => :destroy
  has_many :testpapers, :through => :answer_sheets

  validates :name, :presence => true
  validates_associated :account

  before_destroy :destroyable? 

  attr_accessor :code

  def self.name_begins_with( allowed = [] )
    return if allowed.empty? 
    select{ |m| allowed.include? m.first_name[0] }
  end

  def self.min_levenshtein_distance(x,y)
    # (x,y) -> two names
    xa = x.split
    ya = y.split
    min = -1

    for i in xa 
      for j in ya
        dist = Levenshtein.distance(i,j)
        min = (min != -1) ? (dist < min ? dist : min): dist
        return min if min == 0
      end
    end
    return min
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
    name.gsub! /[\d\.\$\?\(\)\,#]+/,""
    split = name.strip.split
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

    a = AnswerSheet.where(student_id: self.id).where(graded: false)
    # The above will include worksheets that have either: 
    #    1. been partially graded
    #    2. or, have no scans 
    # Filter both of these out before returning

    a = a.select{ |m| m.graded?(:none) } # --> (1) --> only those not graded at all
    ws_ids = a.map(&:testpaper_id)
    without_scans = GradedResponse.in_testpaper(ws_ids).of_student(self.id).without_scan.map(&:testpaper_id).uniq
    ungraded_with_scans = ws_ids - without_scans
    return Testpaper.where(id: ungraded_with_scans)
  end

  def pending
    # Any student worksheet - without scans
    assigned = self.testpapers.map(&:id) 
    g = GradedResponse.in_testpaper(assigned).of_student(self.id).without_scan
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

  private 
    def destroyable?
      # A student can be destroyed if there is no associated data for it
      is_empty = true 
      [AnswerSheet, GradedResponse, StudentRoster].each do |m|
        is_empty = m.where(:student_id => self.id).empty?
        break unless is_empty
      end
      # puts " ++++ Can be destroyed [#{self.id}]" if is_empty
      return is_empty
    end 

end # of class 
