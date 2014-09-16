# == Schema Information
#
# Table name: stabs
#
#  id          :integer         not null, primary key
#  student_id  :integer
#  examiner_id :integer
#  quality     :integer         default(-1)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  uid         :integer
#  question_id :integer
#  version     :integer
#  puzzle      :boolean         default(TRUE)
#

class Stab < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :student 
  belongs_to :examiner 
  belongs_to :question 

  has_many :kaagaz, dependent: :destroy 

  validates :quality, numericality: { only_integer: true, less_than: 7 } # quality = [-1,6]

  after_create :update_student_behaviour 

  def self.graded
    where('quality > ?', -1) 
  end 

  def self.ungraded 
    where('quality = ?', -1) 
  end 

  def self.unassigned 
    where(examiner_id: nil)
  end 

  def self.with_scan 
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

  def num_credits?
    # number of credits to deduct 
    return 0
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

  private 
        
        def update_student_behaviour
          b = student.behaviour 
          b = b.nil? ? student.create_behaviour : b
          field = puzzle ? :n_puzzles : :n_stabs 
          b.up_count field
        end 

end
