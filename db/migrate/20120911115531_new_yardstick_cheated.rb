class NewYardstickCheated < ActiveRecord::Migration
  def up
    y = Yardstick.new :weight => 0, :insight => true, :bottomline => "No",
    :meaning => %q(Not convinced that the work done is the student's own genuine effort)
    y.save
  end

  def down
  end
end
