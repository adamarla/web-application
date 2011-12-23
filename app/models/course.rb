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

  # [:name,:board_id,:klass,:subject] ~> [:admin] 
  #attr_accessible 

  def update_syllabus( options ) 
    # options = params[:syllabi] in 'update' action in SyllabiController 

    topics = [] 
    status = :ok 

    options.each do |topic_id, difficulty| 
      topic = SpecificTopic.find topic_id
      unless topic.nil? 
        topics << topic 
      else 
        status = :bad_request 
      end #unless 
      break if status == :bad_request # retain old syllabus if anything wrong w/ new one 
    end #each 

    unless status == :bad_request 
      self.micro_topics = topics # updates the syllabus join table !
      # Now, update the difficulty levels for each topic for this course

      options.each do |topic_id, difficulty|
        syllabus = Syllabus.where(:course_id => self.id, :micro_topic_id => topic_id).first 
        status = syllabus.update_attributes(difficulty) ? :ok : :bad_request
      end 
    end # unless  

    return status  
  end # of function

end
