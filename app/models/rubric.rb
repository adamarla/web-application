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
#  active     :boolean         default(FALSE)
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
    # returns the number of criteria in this rubric. By default, returns the 
    # number of active criteria
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

  def fdb_and_penalty_given(criterion_ids)
    # We are intentionally not considering just the active criteria. 
    # Its possible that the rubric owner is making changes while graders are grading. 
    # In which case, the graders would see the old rubric till such time that they 
    # reload. The choice then is of either not recording some of what the grader 
    # says OR recording irrespective of whether some criteria are now inactive. We 
    # choose to do the latter 

    criteria = Checklist.where(rubric_id: self.id).order(:index)

    mangled_fdb = 0 
    penalty = 0 

    ids = criteria.map(&:criterion_id)
    indices = criteria.map(&:index)
    penalties = criteria.map(&:criterion).map(&:penalty)

    for m in criterion_ids
      j = ids.index m
      next if j.nil?
      mangled_fdb |= ( 1 << indices[j] )
      penalty += penalties[j]
    end 
    penalty = (penalty > 100) ? 100 : penalty 
    return mangled_fdb, penalty
  end 

  def criteria_ids_given(mangled_fdb)
    criteria = Checklist.where(rubric_id: self.id).order(:index)
    ret = [] 

    for j in criteria  
      ret.push(j.criterion_id) if ((mangled_fdb & ( 1 << j.index )) != 0 )
    end 
    return ret
  end 

  def colour?(mangled_fdb) 
    # Returns one of :red, :orange, :green or :blank
    return :blank if mangled_fdb == 0 
    criteria = Criterion.where(id: self.criteria_ids_given(mangled_fdb))
    return :red if criteria.map(&:red_flag).include?(true)
    return :orange if criteria.map(&:orange_flag).include?(true)
    return :green
  end 

end
