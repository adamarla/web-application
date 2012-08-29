class NewYardstickNotConvinced < ActiveRecord::Migration
  def up
    y = Yardstick.new :weight => 0, :insight => true, :bottomline => "No",
    :meaning => %q(Cannot give credit for insights because the work shown is not convincing)
    y.save
  end

  def down
  end
end
