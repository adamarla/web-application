class AddTimeToBingoToAttempts < ActiveRecord::Migration
  def change
    add_column :attempts, :time_to_bingo, :integer, default: 0
  end
end
