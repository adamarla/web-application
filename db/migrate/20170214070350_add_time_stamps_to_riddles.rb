class AddTimeStampsToRiddles < ActiveRecord::Migration
  def change
    add_timestamps :riddles 
  end
end
