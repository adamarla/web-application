# == Schema Information
#
# Table name: study_groups
#
#  id         :integer         not null, primary key
#  school_id  :integer
#  klass      :integer
#  section    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class StudyGroup < ActiveRecord::Base
  validates :klass, :presence => true 
  validates :section, :presence => true 

  validates :section, :uniqueness => { :scope => [:klass, :school_id] } 

  belongs_to :school
  has_many :students

  has_many :faculty_rosters
  has_many :teachers, :through => :faculty_rosters

  def label? 
    return "#{self.klass.to_s}-#{self.section.upcase}"
  end 

  def name 
    self.klass + '-' + self.section
  end 

end
