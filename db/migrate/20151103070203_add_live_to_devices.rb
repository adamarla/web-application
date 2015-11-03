class AddLiveToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :live, :boolean, default: true 
  end
end
