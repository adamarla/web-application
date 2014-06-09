# == Schema Information
#
# Table name: rubrics
#
#  id         :integer         not null, primary key
#  name       :string(100)
#  teacher_id :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Rubric < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :name, presence: true
  has_many :checklists 
  has_many :criteria, through: :checklists

  def self.standard 
    where(teacher_id: nil)
  end 
end
