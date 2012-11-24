class NewYardstickHonestErrors < ActiveRecord::Migration
  def up
    y = Yardstick.new :weight => 2, :formulation => true,
        :bottomline => "Yes - to some extent",
        :meaning => %q(Follow up work has some errors. But overall, an honest attempt)
    y.save
  end

  def down
  end
end
