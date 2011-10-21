# == Schema Information
#
# Table name: study_groups
#
#  id         :integer         not null, primary key
#  school_id  :integer
#  grade      :integer
#  section    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class StudyGroup < ActiveRecord::Base
  validates :grade, :presence => true 
  validates :section, :presence => true 

  belongs_to :school

  def label? 
    return "#{self.grade.to_s}-#{self.section.upcase}"
  end 

end
