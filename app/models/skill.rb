# == Schema Information
#
# Table name: skills
#
#  id         :integer         not null, primary key
#  chapter_id :integer
#  generic    :boolean         default(FALSE)
#

class Skill < ActiveRecord::Base
  has_one :sku, as: :stockable, dependent: :destroy
  after_create :add_sku 

  private 
    def add_sku 
      self.create_sku path: "skill/#{self.id}"
    end 

end
