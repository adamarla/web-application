# == Schema Information
#
# Table name: chapters
#
#  id         :integer         not null, primary key
#  name       :string(70)
#  level_id   :integer
#  subject_id :integer
#  uid        :string(10)
#

class Chapter < ActiveRecord::Base
  belongs_to :level 
  belongs_to :subject 
  has_many :questions

  validates :name, presence: true 
  validates :name, uniqueness: { scope: [:level_id, :subject_id] }

  before_validation :titleize 
  after_create :set_uid 

  def titleize 
    self.name = self.name.titleize unless self.name.blank?
  end 

  def self.quick_add(name) 
    Chapter.create name: name, level_id: Level.named('senior'), subject_id: Subject.named('maths') 
  end 

  def self.generic
    return where(name: "generic".titleize).first
  end 

  private 

    def set_uid 
      # Remove conjunctions from name 
      x = self.name.downcase.gsub /\s+(a|an|and|the|of|in|on)\s+/, ' '  

      code = x.split(' ')[0..1].map{ |tkn| tkn[0..3] }.join.upcase
      self.update_attribute :uid, code
    end 

end
