# == Schema Information
#
# Table name: rubrics
#
#  id         :integer         not null, primary key
#  name       :string(100)
#  account_id :integer
#  standard   :boolean         default(TRUE)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Rubric < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :name, presence: true
  has_many :checklists 
  has_many :criteria, through: :checklists

  def self.standard 
    where(standard: true)
  end 

  def update_criteria(ids)
    # ids = array of criterion IDs 
    # A criterion, once added, is never deleted from the join table ( checklists ). 
    # Instead, if it must be excluded, then only the active field in checklists is flipped 
    # to false. This is done to ensure that any feedback given before exclusion can 
    # be reconstructed correctly 
    # On the downside, this also means that we limit a rubric to having just 32 criteria
    # - including deactivated ones 

    self.criterion_ids = (self.criterion_ids + ids).uniq 
    for m in Checklist.where(rubric_id: self.id)
      is_active = ids.include? m.criterion_id 
      m.update_attribute :active, is_active 
    end 
  end 

  def num_criteria?(type = :active) 
    c = Checklist.where(rubric_id: self.id)
    case type 
      when :active 
        c = c.where(active: true)
      when :inactive 
        c = c.where(active: false)
      else 
        c = c 
    end 
    return c.count 
  end 

end
