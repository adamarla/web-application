# == Schema Information
#
# Table name: specializations
#
#  id         :integer         not null, primary key
#  teacher_id :integer
#  subject_id :integer
#  created_at :datetime
#  updated_at :datetime
#  klass      :integer
#

class Specialization < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :subject
end
