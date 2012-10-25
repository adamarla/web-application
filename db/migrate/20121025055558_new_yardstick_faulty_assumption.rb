class NewYardstickFaultyAssumption < ActiveRecord::Migration
  def up
    y = Yardstick.new :weight => 0, :insight => true, :bottomline => "No",
    :meaning => %q(In fact, student has made assumption(s) that are wrong. Subsequent work will only further a faulty line of reasoning)
    y.save
  end

  def down
  end
end
