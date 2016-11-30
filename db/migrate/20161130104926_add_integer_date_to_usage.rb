class AddIntegerDateToUsage < ActiveRecord::Migration
  def up
    add_column :usages, :idate, :integer, default: 0

    # Convert "Dec 27, 2011" -> 20111227
    Usage.all.each do |u| 
      d = u.date.to_date.to_s.gsub("-","").to_i
      u.update_attribute :idate, d
    end 
  end 

  def down 
    remove_column :usages, :idate
  end 
end
