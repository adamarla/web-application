# == Schema Information
#
# Table name: courses
#
#  id         :integer         not null, primary key
#  name       :string(50)
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

  has_many :topics, :through => :syllabi
  has_many :syllabi

  validates :name, :presence => true
=begin
  validates :klass, :presence => true, \
            :numericality => {:only_integer => true, :greater_than => 0}
  validates :subject_id, :board_id, :presence => true
=end

  def self.klass?(klass = nil)
    klass.blank? ? where('id IS NOT NULL') : where(:klass => klass)
  end 

  def self.subject?(subject = nil)
    subject.blank? ? where('id IS NOT NULL') : where(:subject_id => subject)
  end 

  def self.board?(board = nil)
    board.blank? ? where('id IS NOT NULL') : where(:board_id => board)
  end 

  def covers_vertical?(id)
    a = self.topic_ids 
    b = Vertical.find(id).topic_ids

    return !((a & b).empty?)
  end

  def verticals
    ids = self.topics.map(&:vertical_id).uniq
    return Vertical.where(:id => ids).order(:name)
  end

  def topics_in( vertical )
    topic_ids = Syllabus.where(:course_id => self.id).map(&:topic_id)
    @topics = Topic.where(:id => topic_ids).where(:vertical_id => vertical)
  end

  # [:name,:board_id,:klass,:subject] ~> [:admin] 
  #attr_accessible 

  def update_syllabus( syllabi ) 
    status = :ok
    ids = syllabi.keys.find_all { |key| syllabi[key].to_i > 0 }
    ids = ids.map { |id| id.to_i }
    topics = ids.map { |index| Topic.find index }
    self.topics = topics # requisite additions & deletions to the join-table

    syllabi.each do |id,difficulty| 
      if difficulty.to_i > 0
        item = Syllabus.where(:course_id => self.id, :topic_id => id.to_i).first
        status = item.update_attribute(:difficulty, difficulty.to_i) ? :ok : :bad_request
        break if status == :bad_request
      end
    end 
    return (status == :bad_request) ? :bad_request : :ok
  end # of function

  def questions_on (topic_ids = [], teacher_id = nil)
    @questions = []
    Syllabus.where(:course_id => self.id, :topic_id => topic_ids).each do |j|
      @questions |= Question.on_topic(j.topic_id).difficulty(j.difficulty)
    end

    # If teacher_id is non-nil, then return only those questions 
    # from @questions that have never been used by the said teacher before
    unless teacher_id.nil?
      quiz_ids = Quiz.where(:teacher_id => teacher_id).map(&:id)
      used = QSelection.where(:quiz_id => quiz_ids).map(&:question_id).uniq
      unused = @questions.map(&:id).uniq - used
      @questions = Question.where(:id => unused)
    end
    return @questions.sort{ |m,n| m.topic_id <=> n.topic_id }.sort{ |m,n| m.marks? <=> n.marks? }
  end

end
