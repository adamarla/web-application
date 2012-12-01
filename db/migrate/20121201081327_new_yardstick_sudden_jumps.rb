class NewYardstickSuddenJumps < ActiveRecord::Migration
  def up
    y = Yardstick.new :weight => 0, :formulation => true,
        :bottomline => "No",
        :meaning => %q(Sudden - and unexplained - jumps in follow-up work. Need to see some justification for the jumps in order to give credit)
    y.save
  end

  def down
  end
end
