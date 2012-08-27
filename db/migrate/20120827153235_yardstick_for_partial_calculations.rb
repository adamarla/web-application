class YardstickForPartialCalculations < ActiveRecord::Migration
  def up
    y = Yardstick.new :calculation => true, :weight => 1, 
                      :bottomline => "Yes, to some extent",
       :meaning => "The calculations that have been done are right - but not all required calculations done"
    y.save
  end

  def down
  end
end
