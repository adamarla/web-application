# == Schema Information
#
# Table name: stabs
#
#  id          :integer         not null, primary key
#  student_id  :integer
#  examiner_id :integer
#  question_id :integer
#  puzzle_id   :integer
#  strength    :integer         default(-1)
#  scan        :string(40)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Stab < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :student 
  belongs_to :examiner 
  belongs_to :subpart 
  belongs_to :puzzle 

  has_many :remarks, dependent: :destroy

  # Should we - or should we not - allow students to take multiple stabs at the same question?
  validates :student_id, uniqueness: { scope: :subpart_id }

  def self.graded
    where('strength > ?', -1) 
  end 

  def self.ungraded 
    where('strength IS ?', -1) 
  end 

  def self.with_scan 
    where('scan IS NOT ?', nil)
  end 

  def self.dated(d) # d = date as a string, like 'Dec 27,2001'
    select{ |j| j.created_at.to_date == Date.parse(d) } 
    # Could be expensive. Try calling last in a call chain
  end 

  def self.by(id) 
    where(student_id: id)
  end 

  def self.reviewed_by(id)
    where(examiner_id: id)
  end 

  def self.at_question(id) 
    where(question_id: id)
  end 

  def self.to_puzzle(id) 
    where(puzzle_id: id)
  end 

  def self.weak 
    where('strength > ? AND strength < ?', -1, 2) 
  end 

  def self.medium 
    where('strength > ? AND strength < ?', 1, 4) 
  end 

  def self.strong 
    where('strength = ?', 4) 
  end 

  def self.on_topic(id)
    select{ |j| j.question?.topic_id == id }
  end

  def question? 
    return (self.subpart_id.nil? ? self.puzzle.question : self.subpart.question) 
  end

end
