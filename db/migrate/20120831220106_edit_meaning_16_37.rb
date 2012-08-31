class EditMeaning1637 < ActiveRecord::Migration
  def up
    Yardstick.find(16).update_attribute :meaning, 
    %q(And the initial line of attack is inefficient. Student unlikely to arrive at an answer going down this path)

    Yardstick.find(37).update_attribute :meaning, 
    %q(One or more essential insights missing. Even if the student arrives at an answer, it will most likely be wrong)
  end

  def down
  end
end
