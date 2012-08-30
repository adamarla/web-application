class EditMeaning16 < ActiveRecord::Migration
  def up
    Yardstick.find(16).update_attribute :meaning, 
    %q(And the approach taken is either very inefficient or will not lead to the correct answer)
  end

  def down
  end
end
