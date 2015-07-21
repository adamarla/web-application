# == Schema Information
#
# Table name: students
#
#  id             :integer         not null, primary key
#  guardian_id    :integer
#  first_name     :string(30)
#  last_name      :string(30)
#  created_at     :datetime
#  updated_at     :datetime
#  shell          :boolean         default(FALSE)
#  phone          :string(15)
#  indie          :boolean
#  reward_gredits :integer         default(100)
#  paid_gredits   :integer         default(0)
#

include ApplicationUtil

class Student < ActiveRecord::Base
  before_destroy :destroyable? 
  belongs_to :guardian

  has_one :account, as: :loggable, dependent: :destroy

  has_many :student_rosters, dependent: :destroy 
  has_many :sektions, through: :student_rosters

  has_many :tryouts, dependent: :destroy
  has_many :quizzes, through: :tryouts

  has_many :worksheets, dependent: :destroy
  has_many :exams, through: :worksheets
  has_many :disputes, dependent: :destroy
  has_many :stabs, dependent: :destroy 
  has_many :doubts, dependent: :destroy 

  validates :name, presence: true
  validates_associated :account

  attr_accessor :code
  accepts_nested_attributes_for :account # simple_form_for needs this 

  def self.merge(a,b) 
    # Merging of two student records can happen only if 
    #   1. (neu) one of 'a' or 'b' has an associated account AND 
    #   2. (old) the other one does not

    old = a.shell ? a : (b.shell ? b : nil)
    return false if old.nil?
    neu = a.shell ? (b.shell ? nil : b) : a 
    return false if neu.nil?

    # Transfer worksheets and tryouts from old -> neu 
    [Tryout, Worksheet, StudentRoster].each do |k|
      k.where(student_id: old.id).each do |j|
        j.update_attribute :student_id, neu.id
      end 
    end 

    # if the old has an associated phone #, then transfer it to 
    # the source
    if neu.account.phone.blank?
      unless old.phone.blank?
        neu.account.update_attribute :phone, old.phone
      end
    end 

    new.update_attribute :indie, nil
    old.destroy # the shell account, that is 
    return true
  end 

  def self.min_levenshtein_distance(x,y) 
    # (x,y) -> two student objects 
    # Working with student objects because we want to compare the 
    # sanitized / humanized names we store in the DB

    x_f = x.first_name.blank? ? "" : x.first_name
    x_l = x.last_name.blank? ? "" : x.last_name
    y_f = y.first_name.blank? ? "" : y.first_name
    y_l = y.last_name.blank? ? "" : y.last_name
    score = 0

    score = Levenshtein.distance(x_f,y_f) + Levenshtein.distance(x_l, y_l)
    return score if score < 6 # average 3 differences each in first and last names

    # In Southern India, the norm is to write the last name first and first name last
    # 
    score = Levenshtein.distance(x_f, y_l) + Levenshtein.distance(x_l, y_f)
    return score 
  end 

  def gredits 
    return (self.reward_gredits + self.paid_gredits)
  end 

  def charge(n_gredits)
    # A refund? 
    if n_gredits < 0 
      rwd = self.reward_gredits - n_gredits 
      self.update_attribute :reward_gredits, rwd 
      return true
    end 

    # Else ... 
    # Use the paid_gredits first and then the reward_gredits.
    # Note: This method intentionally does not check whether available gredits >= n_gredits. 
    # If there wasn't enough balance, then the transaction shouldn't have been triggered. 

    paid = rwd = 0
    balance = self.paid_gredits - n_gredits 
    if balance < 0 
      rwd = self.reward_gredits + balance  
    else
      paid = balance 
      rwd = self.reward_gredits
    end
    unless self.indie?
      # for the few non-indie students at DPS, auto top-up gredits 
      # if the post-charge balance < cost of seeing solution (the more expensive option)
      rwd += 50 if (rwd < 5) 
    end 
    # Do NOT replace with update_attributes as that triggers validations on Account. 
    # We could make these columns attr_accessible. But then, we are opening ourselves to mass-assignment
    # attacks. And these are 'money' columns. So, we don't want anyone changing them willy-nilly.
    self.update_attribute :paid_gredits, paid 
    self.update_attribute :reward_gredits, rwd
  end 

  def indie? 
    return self.indie unless self.indie.nil?
    indie = StudentRoster.where(student_id: self.id).count == 0
    self.update_attribute :indie, indie
    return indie
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
    # Returns worksheets for takehome exams that haven't yet been received (at all) 
    return Worksheet.where(student_id: self.id).select{ |j| j.exam.takehome && j.received?(:none) }
  end

  def outbox
    # Returns the worksheets that should be shown in a student's outbox
    # Any student worksheet - with scans - but not yet graded ( at all ) 
    # should be in the outbox

    a = Worksheet.where(student_id: self.id).where(graded: false)
    # The above will include worksheets that have either: 
    #    1. been partially graded
    #    2. or, have no scans 
    # Filter both of these out before returning

    a = a.select{ |m| m.graded?(:none) } # --> (1) --> only those not graded at all
    eids = a.map(&:exam_id)
    without_scans = Tryout.in_exam(eids).of_student(self.id).without_scan.map(&:exam_id).uniq
    ungraded_with_scans = eids - without_scans
    return Exam.where(id: ungraded_with_scans)
  end

  def pending
    # Any student worksheet - without scans
    assigned = self.exams.map(&:id) 
    g = Tryout.in_exam(assigned).of_student(self.id).without_scan
  end

  def teachers
    Teacher.joins(:sektions).where('sektions.id = ?', self.sektion_id)
  end 

  def quiz_ids
    t_ids = Worksheet.where(student_id: self.id).map(&:exam_id)
    quiz_ids = Exam.where(id: t_ids).map(&:quiz_id).uniq
    return quiz_ids
  end

  def score_in?(exam_id)
    w = Worksheet.where(student_id: self.id, exam_id: exam_id).first
    g = w.nil? ? [] : Tryout.where(worksheet_id: w.id)

    return 0 if g.blank?
    return -1 if g.with_scan.count == 0 # absent perhaps?

    if g.ungraded.count > 0
      marks = g.graded.map(&:marks).inject(:+)
    else
      marks = w.marks?
    end
    return (marks.nil? ? 0 : marks.round(2))
  end

  def responses(exam_id)
    a = Tryout.of_student(self.id).in_exam(exam_id).with_scan
    return a.sort{ |m,n| m.q_selection.index <=> n.q_selection.index }
  end

  def expectations_met_in(topic_id)
    # Returns the weighted average percentage earned by a student on
    # a given topic on the questions his/her teacher set
    # Returns: a number in [0,1]
    g = Tryout.of_student(self.id).graded.on_topic(topic_id)
    sids = g.map(&:subpart_id).uniq

    earned = 0 
    [*1..6].each do |marks|
      having = g.select{ |m| m.subpart.marks == marks }
      next if having.count == 0
      avg = (having.map(&:marks).inject(:+) / having.count.to_f).round(2) # avg score on 'k' mark questions
      earned += avg
    end 
    max = Subpart.where(id: sids).map(&:marks).uniq.inject(:+)
    weighted = max.nil? ? 0 : (earned/max).round(2)
  end 

  def absent_for_quiz?(quiz_id)
    tids = Worksheet.where(student_id: self.id).map(&:exam_id)
    qids = Exam.where(id: tids).map(&:quiz_id)
    took_test = qids.include? quiz_id 
    return true if !took_test

    g = Tryout.of_student(self.id).in_quiz(quiz_id).with_scan
    return g.count == 0
  end

  def absent_for_test?(exam_id)
    g = Tryout.of_student(self.id).in_exam(exam_id).with_scan
    return g.count == 0
  end

  def proficiency_chart_for(tid)
    g = Tryout.of_student(self.id).graded
    aggr = AggrByTopic.for_teacher tid
    topics = aggr.map(&:topic_id).uniq
    topics = Topic.where(id: topics).sort{ |m,n| m.name <=> n.name }
    ret = { proficiency: [ { name: 'Example', score: 0.43, benchmark: 3.5, historical_avg: 2.5 } ] }

    topics.each do |t|
      # student-specific
      on_topic = g.on_topic t.id
      next if on_topic.count == 0
      marks = on_topic.map(&:subpart).map(&:marks)
      n_tryouted = marks.count
      total = marks.inject(:+)
      scored = on_topic.map(&:marks).inject(:+)

      # historical average on topic
      d = aggr.for_topic(t.id).first
      ret[:proficiency].push({ id: t.id, name: t.name, score: (scored/total.to_f).round(2), 
                               benchmark: d.benchmark.round(2), historical_avg: d.average.round(2) })
    end
    return ret
  end

  private 
    def destroyable?
      # A student can be destroyed if there is no associated data for it
      is_empty = true 
      [Stab, Worksheet, Tryout, StudentRoster].each do |m|
        is_empty = m.where(student_id: id).empty?
        break unless is_empty
      end
      # puts " ++++ Cannot be destroyed [#{id}]" unless is_empty
      return is_empty
    end 

end # of class 
