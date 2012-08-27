class ChangeYesAndNoBottomlineText < ActiveRecord::Migration
  def up
    Yardstick.where(:bottomline => "Yes, and no").each do |m|
      m.update_attribute :bottomline, "Yes - to some extent"
    end
  end

  def down
  end
end
