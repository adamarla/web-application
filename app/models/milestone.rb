# == Schema Information
#
# Table name: milestones
#
#  id         :integer         not null, primary key
#  name       :string(70)
#  index      :integer         default(-1)
#  course_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Milestone < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :course
  has_many :videos, as: :watchable 
  has_many :quizzes

  after_create :push_to_last 

  def self.in_course(id)
    where(course_id: id).order(:index)
  end

  def push_to_last
    last = Milestone.in_course(self.course_id).where{ index != -1 }.order(:index) 
    index = last.nil? ? 1 : last.index + 1
    self.update_attribute :index, index
  end 
end
