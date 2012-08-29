class EditMeaning36 < ActiveRecord::Migration
  def up
    Yardstick.find(36).update_attribute :meaning, 
    %q(Response lacks coherence and structure. Not convinced insights are genuine)
  end

  def down
  end
end
