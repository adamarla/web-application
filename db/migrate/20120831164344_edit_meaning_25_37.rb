class EditMeaning2537 < ActiveRecord::Migration
  def up
    Yardstick.find(25).update_attribute :meaning, 
    %q(But it would have been nice to see a little more justification for the steps done and/or choices made)

    Yardstick.find(37).update_attribute :meaning, 
    %q(One or more necessary insights missing. Even if the student gets to an answer, it will be most likely be wrong)
  end

  def down
  end
end
