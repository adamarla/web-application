# == Schema Information
#
# Table name: students
#
#  id             :integer         not null, primary key
#  guardian_id    :integer
#  school_id      :integer
#  first_name     :string(255)
#  last_name      :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  study_group_id :integer
#

class Student < ActiveRecord::Base
  belongs_to :guardian
  belongs_to :school
  belongs_to :study_group
  has_one :account, :as => :loggable, :dependent => :destroy

  has_many :graded_responses
  has_many :quizzes, :through => :graded_responses

  # When should a student be destroyed? My guess, some fixed time after 
  # he/she graduates. But as I haven't quite decided what that time should
  # be, I am temporarily disabling all destruction

  before_destroy :destroyable? 

  private 
    def destroyable? 
      return false 
    end 
end
