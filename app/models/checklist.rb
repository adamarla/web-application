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
end
