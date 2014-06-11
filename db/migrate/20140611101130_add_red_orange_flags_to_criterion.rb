class AddRedOrangeFlagsToCriterion < ActiveRecord::Migration
  def change
    add_column :criteria, :red_flag, :boolean, default: false 
    add_column :criteria, :orange_flag, :boolean, default: false 
  end
end
