class EditMeaning16 < ActiveRecord::Migration
  def up
    Yardstick.find(16).update_attribute :meaning, 
    %q(And the approach taken is inefficient. Getting to the right answer unlikely even if given a little more time) 
  end

  def down
  end
end
