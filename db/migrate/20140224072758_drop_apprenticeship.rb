class DropApprenticeship < ActiveRecord::Migration
  def up
    drop_table :apprenticeships 
  end

  def down
  end
end
