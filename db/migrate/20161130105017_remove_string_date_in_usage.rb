class RemoveStringDateInUsage < ActiveRecord::Migration
  def up
    remove_column :usages, :date
    rename_column :usages, :idate, :date
  end

  def down
    rename_column :usages, :date, :idate
    add_column :usages, :date, :string, limit: 30

    # Convert 20111227 -> "Dec 27, 2011"
    Usage.all.each do |u| 
      d = u.idate.to_s.to_date.strftime("%b %d, %Y")
      u.update_attribute :date, d 
    end 
  end # of down 
end
