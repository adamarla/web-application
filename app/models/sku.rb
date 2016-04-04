# == Schema Information
#
# Table name: skus
#
#  id             :integer         not null, primary key
#  stockable_type :string(255)
#  stockable_id   :integer
#  path           :string(255)
#

class Sku < ActiveRecord::Base
  belongs_to :stockable, polymorphic: true 

  def is_question?
    return (self.stockable_type == Question.name)
  end 

  def is_skill?
    return (self.stockable_type == Skill.name)
  end 

  def is_snippet?
    return (self.stockable_type == Snippet.name)
  end 

end
