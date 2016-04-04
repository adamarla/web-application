# == Schema Information
#
# Table name: snippets
#
#  id            :integer         not null, primary key
#  examiner_id   :integer
#  skill_id      :integer
#  num_attempted :integer         default(0)
#  num_correct   :integer         default(0)
#

class Snippet < ActiveRecord::Base
  belongs_to :skill
  has_one :sku, as: :stockable 
  after_create :add_sku 

  def attempted(correctly = false) 
    correctly ? self.update_attributes(num_attempted: self.num_attempted + 1, 
                                       num_correct: self.num_correct + 1)
              : self.update_attribute(:num_attempted, self.num_attempted + 1)
  end 

  private 
    def add_sku 
      self.create_sku path: "snippets/#{self.id}"
    end 

end
