class AddBalanceGuardian < ActiveRecord::Migration
  def up
    add_column :guardians, :balance, :integer
  end

  def down
  end
end
