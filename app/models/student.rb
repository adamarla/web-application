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

  has_many :student_rosters, dependent: :destroy 
  has_many :sektions, through: :student_rosters

  has_one :account, as: :loggable, dependent: :destroy

  has_many :graded_responses, dependent: :destroy
  has_many :quizzes, through: :graded_responses

  has_many :worksheets, dependent: :destroy
  has_many :exams, through: :worksheets
  has_many :disputes, dependent: :destroy

  validates :name, presence: true
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
    assigned = Worksheet.where(:student_id => self.id)
    received = assigned.where(:received => true)
    due = assigned.map(&:exam_id) - received.map(&:exam_id)
    Exam.where(:id => due, :inboxed => true) 
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
    ws_ids = a.map(&:exam_id)
    without_scans = GradedResponse.in_exam(ws_ids).of_student(self.id).without_scan.map(&:exam_id).uniq
    ungraded_with_scans = ws_ids - without_scans
    return Exam.where(id: ungraded_with_scans)
  end

  def pending
    # Any student worksheet - without scans
    assigned = self.exams.map(&:id) 
    g = GradedResponse.in_exam(assigned).of_student(self.id).without_scan
  end

  def teachers
    Teacher.joins(:sektions).where('sektions.id = ?', self.sektion_id)
  end 

  def quiz_ids
    t_ids = Worksheet.where(:student_id => self.id).map(&:exam_id)
    quiz_ids = Exam.where(:id => t_ids).map(&:quiz_id).uniq
    return quiz_ids
  end

  def marks_scored_in(exam_id)
    w = Worksheet.where(student_id: self.id, exam_id: exam_id).first
    g = w.nil? ? [] : GradedResponse.where(worksheet_id: w.id)

    return 0 if g.blank?
    return -1 if g.with_scan.count == 0 # absent perhaps?

    if g.ungraded.count > 0
      marks = g.graded.map(&:marks).inject(:+)
    else
      marks = w.marks?
    end
    return (marks.nil? ? 0 : marks)
  end

  def honestly_attempted? (ws_id)
    a = Worksheet.where(:student_id => self.id, :exam_id => ws_id).first
    return a.nil? ? :disabled : a.honest?
  end

  def responses(exam_id)
    a = GradedResponse.of_student(self.id).in_exam(exam_id).with_scan
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
      avg = (having.map(&:marks).inject(:+) / having.count.to_f).round(2) # avg score on 'k' mark questions
      earned += avg
    end 
    max = Subpart.where(:id => sids).map(&:marks).uniq.inject(:+)
    weighted = max.nil? ? 0 : (earned/max).round(2)
  end 

  def absent_for_quiz?(quiz_id)
    tids = Worksheet.where(:student_id => self.id).map(&:exam_id)
    qids = Exam.where(:id => tids).map(&:quiz_id)
    took_test = qids.include? quiz_id 
    return true if !took_test

    g = GradedResponse.of_student(self.id).in_quiz(quiz_id).with_scan
    return g.count == 0
  end

  def absent_for_test?(exam_id)
    g = GradedResponse.of_student(self.id).in_exam(exam_id).with_scan
    return g.count == 0
  end

  def proficiency(teacher_id)
    of_student = GradedResponse.of_student(self.id).graded
    aggr = AggrByTopic.for_teacher teacher_id
    topics = aggr.map(&:topic_id).uniq
    topics = Topic.where(:id => topics).sort{ |m,n| m.name <=> n.name }
    ret = { :proficiency => [ {:name => "Example", :score => 0.43, :benchmark => 3.5, :historical_avg => 2.5 } ] }

    topics.each do |t|
      # student-specific
      on_topic = of_student.on_topic t.id
      next if on_topic.count == 0
      marks = on_topic.map(&:subpart).map(&:marks)
      n_attempted = marks.count
      total = marks.inject(:+)
      scored = on_topic.map(&:marks).inject(:+)

      # historical average on topic
      agg = aggr.for_topic(t.id).first
      ret[:proficiency].push({ :id => t.id, :name => t.name, 
                               :score => (scored/total.to_f).round(2),
                               :benchmark => agg.benchmark.round(2),
                               :historical_avg => agg.average.round(2) })
    end
    return ret
  end

  private 
    def destroyable?
      # A student can be destroyed if there is no associated data for it
      is_empty = true 
      [Worksheet, GradedResponse, StudentRoster].each do |m|
        is_empty = m.where(:student_id => self.id).empty?
        break unless is_empty
      end
      # puts " ++++ Can be destroyed [#{self.id}]" if is_empty
      return is_empty
    end 

end # of class 
