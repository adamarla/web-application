class EditMeaning262728 < ActiveRecord::Migration
  def up
    Yardstick.find(26).update_attribute :meaning,
      "Correct calculations are not the most important missing piece in the response"
    Yardstick.find(27).update_attribute :meaning,
      "Some errors in the calculations that have been done"
    Yardstick.find(28).update_attribute :meaning,
      "No errors in the calculations that have been done"
  end

  def down
  end
end
