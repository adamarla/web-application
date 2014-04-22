# == Schema Information
#
# Table name: lessons
#
#  id          :integer         not null, primary key
#  title       :string(150)
#  description :text
#  teacher_id  :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class Lesson < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :teacher
  has_one :video, as: :watchable

  def description?
    return self.description || "No description"
  end 
end
