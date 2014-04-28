# == Schema Information
#
# Table name: doodles
#
#  id                 :integer         not null, primary key
#  examiner_id        :integer
#  feedback           :integer         default(0)
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  graded_response_id :integer
#

class Doodle < ActiveRecord::Base
  # attr_accessible :examiner_id, :feedback
  belongs_to :graded_response
  has_many :remarks

  def fdb(ids) 
    # ids = list of Requirement indices extracted from params[:checked] 
    m = Requirement.mangle_into_feedback ids
    self.update_attribute :feedback, m
  end 
end
