class AddLiveToTakehome < ActiveRecord::Migration
  def change
    add_column :takehomes, :live, :boolean, default: true
  end
end
