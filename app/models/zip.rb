# == Schema Information
#
# Table name: zips
#
#  id        :integer         not null, primary key
#  name      :string(25)
#  parcel_id :integer
#  max_size  :integer         default(-1)
#  open      :boolean         default(TRUE)
#

class Zip < ActiveRecord::Base
  belongs_to :parcel
  after_create :seal 

  private 
    def seal 
      p = self.parcel 
      self.update_attribute :name, "#{p.name}-#{self.id}"
      self.update_attribute(:max_size, 10) if p.for_questions?
    end 

end
