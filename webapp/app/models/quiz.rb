# == Schema Information
#
# Table name: quizzes
#
#  id         :integer         not null, primary key
#  teacher_id :integer
#  created_at :datetime
#  updated_at :datetime
#

class Quiz < ActiveRecord::Base
  belongs_to :teacher 
  has_many :questions 
end
