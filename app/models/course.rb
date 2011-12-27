# == Schema Information
#
# Table name: courses
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  board_id   :integer
#  klass      :integer
#  subject_id :integer
#  created_at :datetime
#  updated_at :datetime
#  active     :boolean         default(TRUE)
#

#     __:has_many___      __:has_many___   ____:has_many__
#    |              |    |              | |               |
#  Board --------> Courses ---------> Sp.Topics ---------> Questions
#    |               |  |               | |               |
#    |__:belongs_to__|  |___:has_many___| |__:belongs_to__|
#    

class Course < ActiveRecord::Base
  belongs_to :board 
  belongs_to :subject

  has_many :micro_topics, :through => :syllabi
  has_many :syllabi

  validates :name, :presence => true
  validates :klass, :presence => true, \
            :numericality => {:only_integer => true, :greater_than => 0}
  validates :subject_id, :board_id, :presence => true

  def self.klass?(klass = nil)
    klass.blank? ? where('klass IS NOT NULL') : where(:klass => klass)
  end 

  def self.subject?(subject = nil)
    subject.blank? ? where('subject_id IS NOT NULL') : where(:subject_id => subject)
  end 

  def self.board?(board = nil)
    board.blank? ? where('board_id IS NOT NULL') : where(:board_id => board)
  end 

  def covers_macro_topic?(id)
    micros = Syllabus.where(:course_id => self.id).select(:micro_topic_id)
    micros.each do |topic| 
      micro_id = topic.micro_topic_id
      macro_id = MicroTopic.where(:id => micro_id).select(:macro_topic_id).first.macro_topic_id
      return true if macro_id == id
    end 
    return false
  end

  # [:name,:board_id,:klass,:subject] ~> [:admin] 
  #attr_accessible 

  def update_syllabus( syllabi ) 
    status = :ok
    ids = syllabi.keys.find_all { |key| syllabi[key].to_i > 0 }
    ids = ids.map { |id| id.to_i }
    topics = ids.map { |index| MicroTopic.find index }
    self.micro_topics = topics # requisite additions & deletions to the join-table

    syllabi.each do |id,difficulty| 
      if difficulty.to_i > 0
        item = Syllabus.where(:course_id => self.id, :micro_topic_id => id.to_i).first
        status = item.update_attribute(:difficulty, difficulty.to_i) ? :ok : :bad_request
        break if status == :bad_request
      end
    end 
    return (status == :bad_request) ? :bad_request : :ok
  end # of function

end
