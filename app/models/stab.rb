# == Schema Information
#
# Table name: stabs
#
#  id          :integer         not null, primary key
#  student_id  :integer
#  examiner_id :integer
#  puzzle_id   :integer
#  quality     :integer         default(-1)
#  scan        :string(40)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  subpart_id  :integer
#  uid         :integer
#

class Stab < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :student 
  belongs_to :examiner 
  belongs_to :subpart 
  belongs_to :puzzle 

  has_many :remarks, dependent: :destroy
  validates :quality, numericality: { only_integer: true, less_than: 7 } # quality = [-1,6]

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
    where('scan IS NOT ?', nil)
  end 

  def self.by(id) 
    where(student_id: id)
  end 

  def self.at_question(id) 
    ids = Question.find(id).subpart_ids
    where(subpart_id: ids)
  end 

  def self.at_puzzle(id) 
    where(puzzle_id: id)
  end 

  def self.at_puzzles 
    where('puzzle_id IS NOT ?', nil)
  end 

  def self.at_questions
    where(puzzle_id: nil)
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
    select{ |j| j.question?.topic_id == id }
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

  def question 
    self.subpart.question
  end

  def num_credits?
    # number of credits to deduct 
    return 0
  end 

  def assign_to(exm) # exm = Examiner object - not ID
    self.update_attribute :examiner_id, exm.id
    exm.update_attribute(:n_assigned, exm.n_assigned + 1)

    # Update payment information
    #   1. reduce gredits in student account 
    #   2. add to accounts receivable (AR) of the grader from whom stab taken away.
  end 

  def unassign
    exm = Examiner.find self.examiner_id
    self.update_attribute(:examiner_id, nil) 
    exm.update_attribute :n_assigned, exm.n_assigned - 1

    # Update payment information
    #   1. add back credits to student account 
    #   2. reduce accounts receivable (AR) of the grader from whom stab taken away.
  end 

end
