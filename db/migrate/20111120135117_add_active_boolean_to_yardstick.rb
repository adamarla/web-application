class AddActiveBooleanToYardstick < ActiveRecord::Migration
  def change
    add_column :yardsticks, :active, :boolean, :default => true
    Yardstick.reset_column_information
    Yardstick.all.each {|yardstick| yardstick.update_attribute(:active, true)}
  end
end
