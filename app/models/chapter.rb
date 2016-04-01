# == Schema Information
#
# Table name: chapters
#
#  id         :integer         not null, primary key
#  name       :string(70)
#  level_id   :integer
#  subject_id :integer
#

class Chapter < ActiveRecord::Base
  belongs_to :level 
  belongs_to :subject 
  has_many :questions

  validates :name, presence: true 
  validates :name, uniqueness: { scope: [:level_id, :subject_id] }

  before_validation :titleize 

  def titleize 
    self.name = self.name.titleize unless self.name.blank?
  end 

  def self.quick_add(name) 
    Chapter.create name: name, level_id: Level.named('senior'), subject_id: Subject.named('maths') 
  end 

end
