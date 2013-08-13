# == Schema Information
#
# Table name: lessons
#
#  id          :integer         not null, primary key
#  name        :string(70)
#  description :text
#  history     :boolean         default(FALSE)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  teacher_id  :integer
#

class Lesson < ActiveRecord::Base
  belongs_to :teacher
  has_one :video, as: :watchable

  has_many :lectures
  has_many :milestones, through: :lectures

  validates :name, presence: true
  validates :description, presence: true
  validates_associated :video, as: :watchable

end
