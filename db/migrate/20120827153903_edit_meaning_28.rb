class EditMeaning28 < ActiveRecord::Migration
  def up
    Yardstick.find(28).update_attribute :meaning, 
      "all required calculations done - and done correctly"
  end

  def down
  end
end
