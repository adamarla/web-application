class NewYardstickObviousInsights < ActiveRecord::Migration
  def up
    y = Yardstick.new :weight => 2, :insight => true, :bottomline => "Yes - somewhat",
    :meaning => %q(But the insights are rather obvious. This problem was really more about how equations are laid out and solved)
    y.save
  end

  def down
  end
end
