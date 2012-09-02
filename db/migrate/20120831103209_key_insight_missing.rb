class KeyInsightMissing < ActiveRecord::Migration
  def up
    y = Yardstick.new :weight => 0, :insight => true, :bottomline => "No",
    :meaning => %q(One or more key insights critical to getting the right answer missing. Wrong answer highly likely)
    y.save
  end

  def down
  end
end
