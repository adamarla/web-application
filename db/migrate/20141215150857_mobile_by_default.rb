class MobileByDefault < ActiveRecord::Migration
  def up
    change_column_default :attempts, :mobile, true
  end

  def down
    change_column_default :attempts, :mobile, false
  end
end
