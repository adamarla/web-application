# == Schema Information
#
# Table name: checklists
#
#  id           :integer         not null, primary key
#  rubric_id    :integer
#  criterion_id :integer
#  index        :integer
#  active       :boolean         default(FALSE)
#

class Checklist < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :criterion
  belongs_to :rubric
  after_create :seal 

  private 
    def seal 
      siblings = Checklist.where(rubric_id: self.rubric_id).where('index IS NOT ?', nil).order(:index)
      index = siblings.last.nil? ? 0 : (siblings.last.index + 1)
      self.update_attribute :index, index
    end 
end
