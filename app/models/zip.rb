# == Schema Information
#
# Table name: zips
#
#  id        :integer         not null, primary key
#  name      :string(25)
#  parcel_id :integer
#  max_size  :integer         default(-1)
#  open      :boolean         default(TRUE)
#  shasum    :string(10)
#

class Zip < ActiveRecord::Base
  belongs_to :parcel
  has_many :skus, through: :inventory 
  after_create :seal 

  def path 
    return "zips/#{self.name}.zip"
  end 

  private 
    def seal 
      p = self.parcel 
      self.update_attribute :name, "#{p.name}-#{self.id}"
      self.update_attribute(:max_size, 10) if p.for_questions?
    end 

end
