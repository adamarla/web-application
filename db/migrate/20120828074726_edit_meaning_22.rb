class EditMeaning22 < ActiveRecord::Migration
  def up
    Yardstick.find(22).update_attributes :formulation => true, 
    :meaning => "Follow-up work is more incomplete than complete",
    :bottomline => "No"
  end

  def down
  end
end
