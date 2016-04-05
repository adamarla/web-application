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
#  modified  :boolean         default(FALSE)
#

class Zip < ActiveRecord::Base
  belongs_to :parcel
  has_many :skus, through: :inventory 

  around_update :set_modified, if: :sku_ids_changed?
  after_create :seal 

  def path 
    return "zips/#{self.name}.zip"
  end 

  def has?(sku)
    return self.sku_ids.include? sku.id
  end 

  def unset_modified
    self.update_attribute :modified, false
  end 

  private 
    def seal 
      p = self.parcel 
      self.update_attribute :name, "#{p.name}-#{self.id}"
      self.update_attribute(:max_size, 10) if p.for_questions?
    end 

    def set_modified
      self.update_attribute :modified, true 
      yield 

      unless self.max_size == -1 
        # A zip once closed for addition CANNOT be opened again
        self.update_attribute(:open, false) if (self.open && self.sku_ids.count >= self.max_size)
      end 
    end 

end # of class 
