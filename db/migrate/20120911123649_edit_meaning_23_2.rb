class EditMeaning232 < ActiveRecord::Migration
  def up
    Yardstick.find(23).update_attribute :meaning, 
    %q(An honest attempt - but is either partially complete or has some errors. Not all loose ends tied up)
  end

  def down
  end
end
