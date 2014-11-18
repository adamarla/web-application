# == Schema Information
#
# Table name: stabs
#
#  id               :integer         not null, primary key
#  student_id       :integer
#  examiner_id      :integer
#  quality          :integer         default(-1)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  uid              :integer
#  question_id      :integer
#  version          :integer
#  puzzle           :boolean         default(TRUE)
#  answer_deduct    :integer         default(0)
#  solution_deduct  :integer         default(0)
#  proofread_credit :integer         default(0)
#  first_shot       :integer
#

class Stab < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :student 
  belongs_to :examiner 
  belongs_to :question 

  has_many :kaagaz, dependent: :destroy 

  validates :quality, numericality: { only_integer: true, less_than: 7 } # quality = [-1,6]

  def self.bought_answer 
    where('answer_deduct > ?', 0) 
  end 

  def self.bought_solution 
    where('solution_deduct > ?', 0) 
  end 

  def self.self_checked 
    where('first_shot <> ?', nil)
  end 

  def self.graded
    where('quality > ?', -1) 
  end 

  def self.ungraded 
    where('quality = ?', -1) 
  end 

  def self.assigned_to(id) 
    where(examiner_id: id)
  end 

  def self.unassigned 
    where(examiner_id: nil)
  end 

  def self.with_scan 
    where('uid IS NOT ?', nil)
  end 

  def self.uploaded # synonym of with_scan
    where('uid IS NOT ?', nil)
  end 

  def self.at_puzzle(id) 
    qid = Puzzle.where(id: id).map(&:question_id).first 
    where(question_id: qid, puzzle: true)
  end 

  def self.blank 
    where(quality: 0)
  end 

  def self.poor
    where('quality > ? AND quality < ?', 0, 3) 
  end

  def self.fair
    where('quality > ? AND quality < ?', 2, 5)
  end 

  def self.good
    where(quality: 5) 
  end 

  def self.perfect 
    where(quality: 6)
  end 

  def self.bell_curve(qid)
    graded = Stab.where(question_id: qid).graded
    n = graded.count 

    ret = [] 
    [*0...6].each do |j|
      m = graded.where(quality: j).count
      p = n > 0 ?  (m.to_f * 100/n).round(2) : 0 
      tag = Stab.quality_defn(j)
      ret.push({ tag: tag, p: p })
    end 
    return ret
  end 

  def self.quality_defn(n)
    return 'Not graded' if n < 0
    return ['Blank / little done', 
            'Unimpressed', 
            'Mildly impressed', 
            'Reasonably impressed', 
            'Quite impressed', 
            'Very impressed / Perfect'][n]
  end 

  def self.on_topic(id)
    select{ |j| j.question.topic_id == id }
  end

  def self.date_to_uid(date)
    # date = any valid string that represents a date and can be passed to Date.parse 
    return nil if date.blank?
    d = Date.parse(date)
    return d.strftime('%d%m%y').to_i
  end 

  def self.uid_to_date(uid)
    return 'Unknown' if uid.blank?
    year = uid % 100 
    month = (uid / 100) % 100 
    day = uid / 10000
    return Date.strptime("#{day}/#{month}/#{year}", "%d/%m/%y")
  end 

  def self.received_on(d) # d = date as a string, like 'Dec 27,2001'
    uid = Stab.date_to_uid(d) 
    where(uid: uid)
  end 

  ###############################################################################
  ##
  ##      QUERY METHODS ON INDIVIDUAL STABS 
  ##
  ###############################################################################

  def bullseye?
    return nil if self.first_shot.nil?
    return self.first_shot == self.version
  end 

  def self_checked?
    return !self.first_shot.nil?
  end 

  def uploaded?
    return !self.uid.blank?
  end 

  def paid_to_see(what) # what = :answer | :solution
    if what == :answer 
      return self.answer_deduct > 0
    elsif what == :solution
      return self.solution_deduct > 0
    end 
    return false
  end 

  # If a student correctly identifies and reports an error in either 
  # our answer or solution, then he/she must be rewarded for it. For now, 
  # we give 3 reward_gredits to them 

  def give_proofreading_reward 
    s = self.student 
    n = s.reward_gredits + 3 
    s.update_attribute :reward_gredits, n
  end 

  # BIG ONE: Returns the enabled/disabled state for the various menu-entries 
  # in the mobile app for this stab 

  def menu_state 
    s = self.student 
    n = s.gredits 
    q = self.question 

    seen_solution = self.paid_to_see(:solution)
    enable_self_check = self.self_checked? || (!seen_solution && q.has_codex?)
    enable_upload = !(seen_solution || self.uploaded?)
    enable_answer = self.paid_to_see(:answer) || (!seen_solution && q.has_answer? && n >= q.price_to_see(:answer))
    enable_solution = seen_solution || (n >= q.price_to_see(:solution))

    return { 
      check: enable_self_check, 
      grade: enable_upload,
      answer: enable_answer, 
      solution: enable_solution, 
      proofread: true
    } 
  end 

  ###############################################################################
  ##
  ##      END OF QUERY METHODS 
  ##
  ###############################################################################

  def charge( what ) # what = :answer | :solution 
    db_column = "#{what.to_s}_deduct" 
    return false if self[db_column] > 0 # already charged. Do NOT double-charge

    price = self.question.price_to_see( what )
    self.student.charge price
    self.update_attribute(db_column, price)
    return price
  end 

  def add_scan(path)
    # Gotcha! Scans will be added in the order in which they are received. 
    # There is no guarantee, therefore, that the order in which scans are seen 
    # also captures the order in which the subparts are

    self.kaagaz.create path: path
  end 

  def assign_to(exm) # exm = Examiner object - not ID
    return false if self.examiner_id == exm.id 
    self.unassign
    self.update_attribute :examiner_id, exm.id
    exm.update_attribute(:n_assigned, exm.n_assigned + 1)

    # Update payment information
    #   1. reduce gredits in student account 
    #   2. add to accounts receivable (AR) of the grader to whom stab is now assigned. 
  end 

  def unassign
    exm = Examiner.find self.examiner_id
    self.update_attribute(:examiner_id, nil) 
    exm.update_attribute :n_assigned, exm.n_assigned - 1
    self.reset(false) # delete remarks added by old grader

    # Update payment information
    #   1. add back credits to student account 
    #   2. reduce accounts receivable (AR) of the grader from whom stab taken away.
  end 

  def reset(soft = true)
    # For times when a stab has to be re-graded, Likely reasons: 
    #     1. re-assigning a stab from one grader to another 
    #     2. de-bugging 
    self.update_attribute :quality, -1 
    self.remarks.map(&:destroy) unless soft
  end 

  def remarks 
    Remark.where(kaagaz_id: self.kaagaz_ids)
  end 

  #########################################
  # Remove later: Clones stabs. Added to create dummy data for de-bugging
  #########################################
  def self.clone(id = nil) 
    master = id.nil? ? Stab.last : Stab.find(id)
    return false if master.nil?

    # Stabs always made for student-ID = 1920 (unhygienix2014@gmail.com) and 
    # always assigned to examiner-ID = 17 (haddock@drona.com)
    stb = Stab.create student_id: 1920, examiner_id: 17, question_id: master.question_id, 
                      version: rand(4), uid: master.uid, puzzle: [true,false].sample 

    # Clone associated scans too
    for kgz in master.kaagaz
      stb.kaagaz.create path: kgz.path 
    end 
  end 

  def self.from_school(id)
    tids = School.find(id).teachers.map(&:id)
    sk_ids = Sektion.where(teacher_id: tids).map(&:id).uniq
    s_ids = StudentRoster.where(sektion_id: sk_ids).map(&:student_id).uniq 
    Stab.where(student_id: s_ids).order(:student_id)
  end 

end # of class
