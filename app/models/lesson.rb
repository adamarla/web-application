# == Schema Information
#
# Table name: lessons
#
#  id          :integer         not null, primary key
#  title       :string(70)
#  description :text
#  history     :boolean         default(FALSE)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Lesson < ActiveRecord::Base
  has_one :video, as: :watchable

  has_many :lectures
  has_many :milestones, through: :lectures

end
