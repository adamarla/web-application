# == Schema Information
#
# Table name: zips
#
#  id        :integer         not null, primary key
#  name      :string(50)
#  parcel_id :integer
#  max_size  :integer         default(-1)
#  open      :boolean         default(TRUE)
#  shasum    :string(10)
#  modified  :boolean         default(FALSE)
#

class Zip < ActiveRecord::Base
  belongs_to :parcel
  has_many :inventory
  has_many :skus, through: :inventory, after_add: :set_modified, after_remove: :set_modified 

  after_create :seal 
  around_update :set_open_boolean, if: :max_size_changed?

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
        name = "#{p.name}-Z#{self.id}"
        self.update_attributes name: name, max_size: p.max_zip_size
      end 

      def set_modified(sku)
        self.update_attribute(:modified, true) unless self.modified 
        return if self.max_size == -1 # Zips for Skills  

        # Close a zip when it is *completely* full 
        # Re-open it only when it is *completely* empty 
        n = self.sku_ids.count 
        if n >= self.max_size 
          self.update_attribute :open, false 
        elsif n == 0 
          self.update_attribute :open, true 
        end 
      end 

      def set_open_boolean 
        self.open = (self.max_size == -1) || (self.sku_ids.count < self.max_size) 
        yield
      end 

end # of class 
