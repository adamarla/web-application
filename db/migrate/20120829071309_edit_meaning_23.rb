class EditMeaning23 < ActiveRecord::Migration
  def up
    Yardstick.find(23).update_attribute :meaning, 
    %q(An honest attempt - but only partially complete and possibly with some errors. Not all loose ends tied up)
  end

  def down
  end
end
