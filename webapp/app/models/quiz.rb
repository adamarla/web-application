# == Schema Information
#
# Table name: quizzes
#
#  id            :integer         not null, primary key
#  teacher_id    :integer
#  created_at    :datetime
#  updated_at    :datetime
#  uid           :string(255)
#  num_students  :integer
#  num_questions :integer
#

class Quiz < ActiveRecord::Base
  belongs_to :teacher 
  has_many :questions 

  validates :teacher_id, :presence => true, :numericality => true
  validates :num_questions, :num_students,  \
            :numericality => {:only_integer => true, :greater_than => 0}, \
            :on => :create

  after_create :set_uid

  def prepare_for(students)
    # students : an array of selected students from the DB
  end 

  def teacher 
    Teacher.find self.teacher_id
  end 

  private 

    def set_uid 
      # Each quiz is given a unique ID. Within it is information about 
      # the issuing teacher, # of students taking the quiz, index in DB etc. etc.
      # which is really important at our end. 

      # This UID is then mixed with student specific information to make the 
      # student specific QR code. Note that this function can only be called 
      # after_create because till then no self.id has been assigned

      a = [self.id, self.teacher_id, self.num_questions, self.num_students] 
      uid = "" 

      a.each { |b|
        uid += "#{b.to_s(36).upcase}"
      }
      self.update_attribute :uid, uid
    end 
end
