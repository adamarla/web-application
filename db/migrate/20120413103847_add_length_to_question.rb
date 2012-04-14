class AddLengthToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :length, :float
  end
end
