class GiveFreeGredits < ActiveRecord::Migration
  def up
    change_column_default :students, :gredits, 100
  end

  def down
    change_column_default :students, :gredits, 0
  end
end
