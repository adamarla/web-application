# == Schema Information
#
# Table name: disputes
#
#  id         :integer         not null, primary key
#  student_id :integer
#  attempt_id :integer
#  text       :text
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Dispute < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :student 

  def self.by(id)
    where(student_id: id)
  end 

  def self.in_exam(id)
    gids = Attempt.in_exam(id).map(&:id)
    where(attempt_id: gids)
  end

end
