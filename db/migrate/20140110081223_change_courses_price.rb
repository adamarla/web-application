class ChangeCoursesPrice < ActiveRecord::Migration
  def up
    change_table :courses do |t|
      t.change :price, :integer
    end
  end

  def down
  end
end
