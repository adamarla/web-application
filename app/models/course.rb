# == Schema Information
#
# Table name: courses
#
#  id         :integer         not null, primary key
#  name       :string(50)
#  teacher_id :integer
#  created_at :datetime
#  updated_at :datetime
#  price      :decimal(5, 2)
#

class Course < ActiveRecord::Base
  validates :name, presence: true
  validates :teacher_id, presence: true

  has_many :concepts
end
