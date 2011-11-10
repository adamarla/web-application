# == Schema Information
#
# Table name: grade_descriptions
#
#  id                :integer         not null, primary key
#  annotation        :string(255)
#  description       :string(255)
#  default_allotment :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class GradeDescription < ActiveRecord::Base
  has_many :grades
  has_many :teachers, :through => :grades 

  validates :annotation, :presence => true 
  validates :default_allotment, :presence => true, 
            :numericality => {:only_integer => true, 
                              :less_than_or_equal_to => 100}
end
