class EditMeaning2223 < ActiveRecord::Migration
  def up
    Yardstick.find(22).update_attribute :meaning, 
        "Follow-up work is more incomplete than complete OR has some errors"
    Yardstick.find(23).update_attribute :meaning,
        "An honest attempt with no serious errors - but with some loose ends"
  end

  def down
  end
end
