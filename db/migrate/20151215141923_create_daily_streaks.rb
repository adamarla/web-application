class CreateDailyStreaks < ActiveRecord::Migration
  def change
    create_table :daily_streaks do |t|
      t.string :date, limit: 30 
      t.integer :pupil_id
      t.integer :streak_total, default: 0
    end
  end
end
