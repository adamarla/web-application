class AddGreditsToStudent < ActiveRecord::Migration
  def change
    add_column :students, :gredits, :integer, default: 0
  end
end
