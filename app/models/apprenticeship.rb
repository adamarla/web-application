# == Schema Information
#
# Table name: apprenticeships
#
#  id          :integer         not null, primary key
#  examiner_id :integer
#  teacher_id  :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Apprenticeship < ActiveRecord::Base
  attr_accessible :examiner_id, :teacher_id

  belongs_to :examiner
  belongs_to :teacher
end
