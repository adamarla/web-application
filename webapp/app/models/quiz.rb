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
  belongs_to :db_question, :teacher 
  has_many :questions 

  validates :teacher_id, :presence => true, :numericality => true
  validates :num_questions, :num_students,  \
            :numericality => {:only_integer => true, :greater_than => 0}, \
            :on => :create

  before_create :set_uid

  def prepare_for(students)
    # students : an array of selected students from the DB
  end 

  def teacher 
    Teacher.find self.teacher_id
  end 

  private 

    def set_uid 
      a = [self.id, self.teacher_id, self.num_questions, self.num_students] 
      a.each { |b|
        if self.uid.nil? 
            self.uid = "#{b.to_s(36).upcase}"
        else 
            self.uid += "#{b.to_s(36).upcase}"
        end 
      }
    end 
end
